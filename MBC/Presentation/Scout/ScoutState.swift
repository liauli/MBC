import Foundation

enum ScoutState: Equatable {
    case idle
    case scanning
    case success(MemberCard)
    case error(String)
}
