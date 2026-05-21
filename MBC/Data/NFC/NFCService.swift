import CoreNFC
import Foundation

final class NFCService: NSObject, NFCServiceProtocol {
    private var session: NFCNDEFReaderSession?
    private var readCompletion: ((Result<Data, MBCError>) -> Void)?
    private var writeData: Data?
    private var writeCompletion: ((Result<Void, MBCError>) -> Void)?

    func read(completion: @escaping (Result<Data, MBCError>) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure(.nfcNotAvailable))
            return
        }
        readCompletion = completion
        writeData = nil
        writeCompletion = nil
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Tempelkan kartu ke bagian atas iPhone"
        session?.begin()
    }

    func write(_ data: Data, completion: @escaping (Result<Void, MBCError>) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure(.nfcNotAvailable))
            return
        }
        writeData = data
        writeCompletion = completion
        readCompletion = nil
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Tempelkan kartu ke bagian atas iPhone"
        session?.begin()
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCService: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_: NFCNDEFReaderSession) {}

    func readerSession(_: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let nfcError = error as? NFCReaderError
        guard nfcError?.code != .readerSessionInvalidationErrorFirstNDEFTagRead,
              nfcError?.code != .readerSessionInvalidationErrorUserCanceled
        else { return }
        readCompletion?(.failure(.nfcReadFailed))
        writeCompletion?(.failure(.nfcWriteFailed))
        cleanup()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first else {
            readCompletion?(.failure(.nfcReadFailed))
            cleanup()
            return
        }
        readCompletion?(.success(record.payload))
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
                self?.writeCompletion?(.failure(.nfcWriteFailed))
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
            if let error {
                session.invalidate(errorMessage: "Gagal membaca: \(error.localizedDescription)")
                self?.readCompletion?(.failure(.nfcReadFailed))
            } else if let record = message?.records.first {
                session.alertMessage = "Berhasil membaca kartu"
                session.invalidate()
                self?.readCompletion?(.success(record.payload))
            } else {
                session.invalidate(errorMessage: "Kartu kosong")
                self?.readCompletion?(.failure(.cardNotRegistered))
            }
            self?.cleanup()
        }
    }

    private func performWrite(tag: any NFCNDEFTag, session: NFCNDEFReaderSession, data: Data) {
        let record = NFCNDEFPayload(
            format: .unknown,
            type: Data(),
            identifier: Data(),
            payload: data
        )
        let message = NFCNDEFMessage(records: [record])
        tag.writeNDEF(message) { [weak self] error in
            if error != nil {
                session.invalidate(errorMessage: "Gagal menulis kartu")
                self?.writeCompletion?(.failure(.nfcWriteFailed))
            } else {
                session.alertMessage = "Berhasil menulis kartu"
                session.invalidate()
                self?.writeCompletion?(.success(()))
            }
            self?.cleanup()
        }
    }

    private func cleanup() {
        readCompletion = nil
        writeCompletion = nil
        writeData = nil
        session = nil
    }
}
