import CoreNFC
import Foundation

final class NFCService: NSObject, NFCServiceProtocol {
    private var session: NFCNDEFReaderSession?
    private var readContinuation: CheckedContinuation<Data, Error>?
    private var writeContinuation: CheckedContinuation<Void, Error>?
    private var readWriteContinuation: CheckedContinuation<Data, Error>?
    private var writePayload: Data?
    private var transform: ((Data) throws -> Data)?

    func read() async throws -> Data {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw MBCError.nfcNotAvailable
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.readContinuation = continuation
            self.writePayload = nil
            self.transform = nil
            startSession()
        }
    }

    func write(_ data: Data) async throws {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw MBCError.nfcNotAvailable
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.writeContinuation = continuation
            self.writePayload = data
            self.transform = nil
            startSession()
        }
    }

    func readAndWrite(_ transform: @escaping (Data) throws -> Data) async throws -> Data {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw MBCError.nfcNotAvailable
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.readWriteContinuation = continuation
            self.writePayload = nil
            self.transform = transform
            startSession()
        }
    }

    private func startSession() {
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "Tempelkan kartu ke bagian atas iPhone"
        self.session = session
        session.begin()
    }

    private func cleanup() {
        readContinuation = nil
        writeContinuation = nil
        readWriteContinuation = nil
        writePayload = nil
        transform = nil
        session = nil
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCService: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_: NFCNDEFReaderSession) {}

    func readerSession(_: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let nfcError = error as? NFCReaderError
        guard nfcError?.code != .readerSessionInvalidationErrorFirstNDEFTagRead,
              nfcError?.code != .readerSessionInvalidationErrorUserCanceled
        else {
            cleanup()
            return
        }
        readContinuation?.resume(throwing: MBCError.nfcReadFailed)
        writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
        readWriteContinuation?.resume(throwing: MBCError.nfcReadFailed)
        cleanup()
    }

    func readerSession(_: NFCNDEFReaderSession, didDetectNDEFs _: [NFCNDEFMessage]) {}

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        guard let tag = tags.first else {
            failAll(session: session, message: "Kartu tidak terdeteksi")
            return
        }
        session.connect(to: tag) { [weak self] error in
            guard error == nil else {
                self?.failAll(session: session, message: "Gagal terhubung ke kartu")
                return
            }
            if let transform = self?.transform {
                self?.performReadWrite(tag: tag, session: session, transform: transform)
            } else if let data = self?.writePayload {
                self?.performWrite(tag: tag, session: session, data: data)
            } else {
                self?.performRead(tag: tag, session: session)
            }
        }
    }

    // MARK: - Read Only

    private func performRead(tag: any NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { [weak self] message, error in
            if error != nil {
                session.invalidate(errorMessage: "Gagal membaca kartu")
                self?.readContinuation?.resume(throwing: MBCError.nfcReadFailed)
                self?.cleanup()
                return
            }
            guard let record = message?.records.first else {
                session.invalidate(errorMessage: "Kartu kosong")
                self?.readContinuation?.resume(throwing: MBCError.cardNotRegistered)
                self?.cleanup()
                return
            }
            session.alertMessage = "Kartu terbaca ✓"
            session.invalidate()
            self?.readContinuation?.resume(returning: record.payload)
            self?.cleanup()
        }
    }

    // MARK: - Write Only

    private func performWrite(tag: any NFCNDEFTag, session: NFCNDEFReaderSession, data: Data) {
        let message = createMessage(data)
        tag.writeNDEF(message) { [weak self] error in
            guard error == nil else {
                session.invalidate(errorMessage: "Gagal menulis ke kartu")
                self?.writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
                self?.cleanup()
                return
            }
            session.alertMessage = "Berhasil ✓"
            session.invalidate()
            self?.writeContinuation?.resume()
            self?.cleanup()
        }
    }

    // MARK: - Read then Write (single session)

    private func performReadWrite(
        tag: any NFCNDEFTag,
        session: NFCNDEFReaderSession,
        transform: @escaping (Data) throws -> Data
    ) {
        tag.readNDEF { [weak self] message, error in
            if error != nil {
                session.invalidate(errorMessage: "Gagal membaca kartu")
                self?.readWriteContinuation?.resume(throwing: MBCError.nfcReadFailed)
                self?.cleanup()
                return
            }
            guard let record = message?.records.first else {
                session.invalidate(errorMessage: "Kartu kosong")
                self?.readWriteContinuation?.resume(throwing: MBCError.cardNotRegistered)
                self?.cleanup()
                return
            }
            let inputData = record.payload
            let outputData: Data
            do {
                outputData = try transform(inputData)
            } catch {
                session.invalidate(errorMessage: "Gagal memproses kartu")
                self?.readWriteContinuation?.resume(throwing: error)
                self?.cleanup()
                return
            }
            let writeMessage = self?.createMessage(outputData) ?? NFCNDEFMessage(records: [])
            tag.writeNDEF(writeMessage) { writeError in
                guard writeError == nil else {
                    session.invalidate(errorMessage: "Gagal menulis ke kartu")
                    self?.readWriteContinuation?.resume(throwing: MBCError.nfcWriteFailed)
                    self?.cleanup()
                    return
                }
                session.alertMessage = "Berhasil ✓"
                session.invalidate()
                self?.readWriteContinuation?.resume(returning: outputData)
                self?.cleanup()
            }
        }
    }

    // MARK: - Helpers

    private func createMessage(_ data: Data) -> NFCNDEFMessage {
        let record = NFCNDEFPayload(
            format: .unknown,
            type: "mbc.v1".data(using: .utf8) ?? Data(),
            identifier: Data(),
            payload: data
        )
        return NFCNDEFMessage(records: [record])
    }

    private func failAll(session: NFCNDEFReaderSession, message: String) {
        session.invalidate(errorMessage: message)
        readContinuation?.resume(throwing: MBCError.nfcReadFailed)
        writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
        readWriteContinuation?.resume(throwing: MBCError.nfcReadFailed)
        cleanup()
    }
}
