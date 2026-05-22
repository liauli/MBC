import Foundation

enum StationState: Equatable {
    case idle
    case loading
    case cardBlank
    case cardExists(MemberCard)
    case registerSuccess(MemberCard)
    case topUpReady(MemberCard)
    case topUpSuccess(MemberCard)
    case error(String)
}
