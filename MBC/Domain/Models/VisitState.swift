import Foundation

enum VisitState: Equatable {
    case idle
    case checkedIn(time: Date, isSimulated: Bool)
}
