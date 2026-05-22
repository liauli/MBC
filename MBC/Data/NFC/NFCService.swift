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

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        guard session === self.session else { return }
        let nfcError = error as? NFCReaderError
        let isCancelled = nfcError?.code == .readerSessionInvalidationErrorFirstNDEFTagRead ||
            nfcError?.code == .readerSessionInvalidationErrorUserCanceled
        if !isCancelled {
            readContinuation?.resume(throwing: MBCError.nfcReadFailed)
            writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
            readWriteContinuation?.resume(throwing: MBCError.nfcReadFailed)
        }
        cleanup()
    }

    func readerSession(_: NFCNDEFReaderSession, didDetectNDEFs _: [NFCNDEFMessage]) {}

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        guard let tag = tags.first else {
            failAll(session: session, message: "Kartu tidak terdeteksi")
            return
        }
        session.connect(to: tag) { [self] error in
            guard error == nil else {
                failAll(session: session, message: "Gagal terhubung ke kartu")
                return
            }
            if let transform {
                performReadWrite(tag: tag, session: session, transform: transform)
            } else if let data = writePayload {
                performWrite(tag: tag, session: session, data: data)
            } else {
                performRead(tag: tag, session: session)
            }
        }
    }

    // MARK: - Read Only

    private func performRead(tag: any NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { [self] message, error in
            if error != nil {
                readContinuation?.resume(throwing: MBCError.nfcReadFailed)
                readContinuation = nil
                session.invalidate(errorMessage: "Gagal membaca kartu")
                return
            }
            guard let record = message?.records.first, !record.payload.isEmpty else {
                readContinuation?.resume(throwing: MBCError.cardNotRegistered)
                readContinuation = nil
                session.invalidate(errorMessage: "Kartu kosong")
                return
            }
            readContinuation?.resume(returning: record.payload)
            readContinuation = nil
            session.alertMessage = "Kartu terbaca ✓"
            session.invalidate()
        }
    }

    // MARK: - Write Only

    private func performWrite(tag: any NFCNDEFTag, session: NFCNDEFReaderSession, data: Data) {
        let message = createMessage(data)
        tag.writeNDEF(message) { [self] error in
            guard error == nil else {
                writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
                writeContinuation = nil
                session.invalidate(errorMessage: "Gagal menulis ke kartu")
                return
            }
            writeContinuation?.resume()
            writeContinuation = nil
            session.alertMessage = "Berhasil ✓"
            session.invalidate()
        }
    }

    // MARK: - Read then Write (single session)

    private func performReadWrite(
        tag: any NFCNDEFTag,
        session: NFCNDEFReaderSession,
        transform: @escaping (Data) throws -> Data
    ) {
        tag.readNDEF { [self] message, error in
            if error != nil {
                readWriteContinuation?.resume(throwing: MBCError.nfcReadFailed)
                readWriteContinuation = nil
                session.invalidate(errorMessage: "Gagal membaca kartu")
                return
            }
            guard let record = message?.records.first, !record.payload.isEmpty else {
                readWriteContinuation?.resume(throwing: MBCError.cardNotRegistered)
                readWriteContinuation = nil
                session.invalidate(errorMessage: "Kartu kosong")
                return
            }
            let inputData = record.payload
            let outputData: Data
            do {
                outputData = try transform(inputData)
            } catch {
                readWriteContinuation?.resume(throwing: error)
                readWriteContinuation = nil
                session.invalidate(errorMessage: "Gagal memproses kartu")
                return
            }
            let writeMessage = createMessage(outputData)
            tag.writeNDEF(writeMessage) { [self] writeError in
                guard writeError == nil else {
                    readWriteContinuation?.resume(throwing: MBCError.nfcWriteFailed)
                    readWriteContinuation = nil
                    session.invalidate(errorMessage: "Gagal menulis ke kartu")
                    return
                }
                readWriteContinuation?.resume(returning: outputData)
                readWriteContinuation = nil
                session.alertMessage = "Berhasil ✓"
                session.invalidate()
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
        readContinuation?.resume(throwing: MBCError.nfcReadFailed)
        writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
        readWriteContinuation?.resume(throwing: MBCError.nfcReadFailed)
        readContinuation = nil
        writeContinuation = nil
        readWriteContinuation = nil
        session.invalidate(errorMessage: message)
    }
}
