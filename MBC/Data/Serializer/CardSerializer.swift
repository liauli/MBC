import Foundation

final class CardSerializer: CardSerializerProtocol {
    private static let maxTransactions = 5
    private static let maxNameLength = 32

    func serialize(_ card: MemberCard) throws -> Data {
        var data = Data()
        data.append(contentsOf: encodeIdentity(card.identity))
        data.append(contentsOf: encodeWallet(card.wallet))
        data.append(contentsOf: encodeVisitState(card.visitState))
        data.append(contentsOf: encodeTransactions(card.transactions))
        data.append(contentsOf: encodeCounter(card.writeCounter))
        return data
    }

    func deserialize(_ data: Data) throws -> MemberCard {
        var offset = 0
        let identity = try decodeIdentity(data, offset: &offset)
        let wallet = try decodeWallet(data, offset: &offset)
        let visitState = try decodeVisitState(data, offset: &offset)
        let transactions = try decodeTransactions(data, offset: &offset)
        let counter = try decodeCounter(data, offset: &offset)
        return MemberCard(
            identity: identity,
            wallet: wallet,
            visitState: visitState,
            transactions: transactions,
            writeCounter: counter
        )
    }

    // MARK: - Encode

    private func encodeIdentity(_ identity: MemberIdentity) -> Data {
        var data = Data()
        let idData = identity.memberID.padding(
            toLength: 8,
            withPad: "\0",
            startingAt: 0
        ).data(using: .utf8) ?? Data(count: 8)
        data.append(idData.prefix(8))
        let nameData = identity.name.padding(
            toLength: Self.maxNameLength,
            withPad: "\0",
            startingAt: 0
        ).data(using: .utf8) ?? Data(count: Self.maxNameLength)
        data.append(nameData.prefix(Self.maxNameLength))
        data.append(contentsOf: encodeDate(identity.registeredDate))
        return data
    }

    private func encodeWallet(_ wallet: Wallet) -> Data {
        var data = Data()
        var balance = Int32(wallet.balance)
        data.append(Data(bytes: &balance, count: 4))
        var lastTopUp = Int32(wallet.lastTopUpAmount)
        data.append(Data(bytes: &lastTopUp, count: 4))
        return data
    }

    private func encodeVisitState(_ state: VisitState) -> Data {
        var data = Data()
        switch state {
        case .idle:
            data.append(0)
            data.append(Data(count: 8))
        case let .checkedIn(time, isSimulated):
            data.append(isSimulated ? 2 : 1)
            data.append(contentsOf: encodeDate(time))
        }
        return data
    }

    private func encodeTransactions(_ transactions: [Transaction]) -> Data {
        var data = Data()
        let trimmed = Array(transactions.suffix(Self.maxTransactions))
        data.append(UInt8(trimmed.count))
        for transaction in trimmed {
            data.append(transaction.type.rawValue)
            var amount = Int32(transaction.amount)
            data.append(Data(bytes: &amount, count: 4))
            data.append(contentsOf: encodeDate(transaction.timestamp))
        }
        return data
    }

    private func encodeCounter(_ counter: UInt16) -> Data {
        var value = counter
        return Data(bytes: &value, count: 2)
    }

    private func encodeDate(_ date: Date) -> Data {
        var interval = Int64(date.timeIntervalSince1970)
        return Data(bytes: &interval, count: 8)
    }

    // MARK: - Decode

    private func decodeIdentity(_ data: Data, offset: inout Int) throws -> MemberIdentity {
        guard data.count >= offset + 48 else { throw MBCError.deserializationFailed }
        let idData = data[offset ..< offset + 8]
        offset += 8
        let memberID = String(data: idData, encoding: .utf8)?
            .trimmingCharacters(in: .controlCharacters) ?? ""
        let nameData = data[offset ..< offset + Self.maxNameLength]
        offset += Self.maxNameLength
        let name = String(data: nameData, encoding: .utf8)?
            .trimmingCharacters(in: .controlCharacters) ?? ""
        let registeredDate = try decodeDate(data, offset: &offset)
        return MemberIdentity(memberID: memberID, name: name, registeredDate: registeredDate)
    }

    private func decodeWallet(_ data: Data, offset: inout Int) throws -> Wallet {
        guard data.count >= offset + 8 else { throw MBCError.deserializationFailed }
        let balance = data.withUnsafeBytes { buf in
            buf.load(fromByteOffset: offset, as: Int32.self)
        }
        offset += 4
        let lastTopUp = data.withUnsafeBytes { buf in
            buf.load(fromByteOffset: offset, as: Int32.self)
        }
        offset += 4
        return Wallet(balance: Int(balance), lastTopUpAmount: Int(lastTopUp))
    }

    private func decodeVisitState(_ data: Data, offset: inout Int) throws -> VisitState {
        guard data.count >= offset + 9 else { throw MBCError.deserializationFailed }
        let flag = data[offset]
        offset += 1
        let time = try decodeDate(data, offset: &offset)
        switch flag {
        case 0: return .idle
        case 1: return .checkedIn(time: time, isSimulated: false)
        case 2: return .checkedIn(time: time, isSimulated: true)
        default: throw MBCError.deserializationFailed
        }
    }

    private func decodeTransactions(_ data: Data, offset: inout Int) throws -> [Transaction] {
        guard data.count >= offset + 1 else { throw MBCError.deserializationFailed }
        let count = Int(data[offset])
        offset += 1
        var transactions: [Transaction] = []
        for _ in 0 ..< count {
            guard data.count >= offset + 13 else { throw MBCError.deserializationFailed }
            guard let type = TransactionType(rawValue: data[offset]) else {
                throw MBCError.deserializationFailed
            }
            offset += 1
            let amount = data.withUnsafeBytes { buf in
                buf.load(fromByteOffset: offset, as: Int32.self)
            }
            offset += 4
            let timestamp = try decodeDate(data, offset: &offset)
            transactions.append(Transaction(type: type, amount: Int(amount), timestamp: timestamp))
        }
        return transactions
    }

    private func decodeCounter(_ data: Data, offset: inout Int) throws -> UInt16 {
        guard data.count >= offset + 2 else { throw MBCError.deserializationFailed }
        let value = data.withUnsafeBytes { buf in
            buf.load(fromByteOffset: offset, as: UInt16.self)
        }
        offset += 2
        return value
    }

    private func decodeDate(_ data: Data, offset: inout Int) throws -> Date {
        guard data.count >= offset + 8 else { throw MBCError.deserializationFailed }
        let interval = data.withUnsafeBytes { buf in
            buf.load(fromByteOffset: offset, as: Int64.self)
        }
        offset += 8
        return Date(timeIntervalSince1970: TimeInterval(interval))
    }
}
