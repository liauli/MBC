import CoreNFC
import Foundation

final class NFCService: NSObject, NFCServiceProtocol {
    private var session: NFCNDEFReaderSession?
    private var continuation: CheckedContinuation<Data, Error>?
    private var writeContinuation: CheckedContinuation<Void, Error>?
    private var writeData: Data?

    func read() async throws -> Data {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw MBCError.nfcNotAvailable
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.writeData = nil
            self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            self.session?.alertMessage = "Tempelkan kartu ke bagian atas iPhone"
            self.session?.begin()
        }
    }

    func write(_ data: Data) async throws {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw MBCError.nfcNotAvailable
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.writeContinuation = continuation
            self.writeData = data
            self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            self.session?.alertMessage = "Tempelkan kartu ke bagian atas iPhone"
            self.session?.begin()
        }
    }
}

extension NFCService: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_: NFCNDEFReaderSession) {}

    func readerSession(_: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let nfcError = error as? NFCReaderError
        guard nfcError?.code != .readerSessionInvalidationErrorFirstNDEFTagRead,
              nfcError?.code != .readerSessionInvalidationErrorUserCanceled
        else { return }
        continuation?.resume(throwing: MBCError.nfcReadFailed)
        writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
        cleanup()
    }

    func readerSession(_: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first else {
            continuation?.resume(throwing: MBCError.nfcReadFailed)
            cleanup()
            return
        }
        continuation?.resume(returning: record.payload)
        cleanup()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "Kartu tidak terdeteksi")
            return
        }
        session.connect(to: tag) { [weak self] error in
            guard error == nil else {
                session.invalidate(errorMessage: "Koneksi gagal")
                self?.writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
                self?.cleanup()
                return
            }
            if let data = self?.writeData {
                self?.performWrite(tag: tag, session: session, data: data)
            } else {
                self?.performRead(tag: tag, session: session)
            }
        }
    }

    private func performRead(tag: any NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { [weak self] message, error in
            if error != nil {
                session.invalidate(errorMessage: "Gagal membaca kartu")
                self?.continuation?.resume(throwing: MBCError.nfcReadFailed)
            } else if let record = message?.records.first {
                session.alertMessage = "Berhasil membaca kartu"
                session.invalidate()
                self?.continuation?.resume(returning: record.payload)
            } else {
                session.invalidate(errorMessage: "Kartu kosong")
                self?.continuation?.resume(throwing: MBCError.cardNotRegistered)
            }
            self?.cleanup()
        }
    }

    private func performWrite(tag: any NFCNDEFTag, session: NFCNDEFReaderSession, data: Data) {
        let record = NFCNDEFPayload(format: .unknown, type: Data(), identifier: Data(), payload: data)
        let message = NFCNDEFMessage(records: [record])
        tag.writeNDEF(message) { [weak self] error in
            if error != nil {
                session.invalidate(errorMessage: "Gagal menulis kartu")
                self?.writeContinuation?.resume(throwing: MBCError.nfcWriteFailed)
            } else {
                session.alertMessage = "Berhasil menulis kartu"
                session.invalidate()
                self?.writeContinuation?.resume(returning: ())
            }
            self?.cleanup()
        }
    }

    private func cleanup() {
        continuation = nil
        writeContinuation = nil
        writeData = nil
        session = nil
    }
}
