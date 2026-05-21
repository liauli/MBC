import Foundation

struct MemberCard: Equatable {
    let identity: MemberIdentity
    var wallet: Wallet
    var visitState: VisitState
    var transactions: [Transaction]
    var writeCounter: UInt16
}
