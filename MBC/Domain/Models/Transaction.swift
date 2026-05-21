import Foundation

struct Transaction: Equatable {
    let type: TransactionType
    let amount: Int
    let timestamp: Date
}

enum TransactionType: UInt8, Equatable {
    case topUp = 1
    case checkIn = 2
    case checkOut = 3
}
