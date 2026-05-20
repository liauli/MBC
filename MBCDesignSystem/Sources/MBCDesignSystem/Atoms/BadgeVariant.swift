import SwiftUI

public enum BadgeVariant {
    case success
    case warning
    case error

    var background: Color {
        switch self {
        case .success: return DSColor.successLight
        case .warning: return DSColor.warningLight
        case .error: return DSColor.errorLight
        }
    }

    var foreground: Color {
        switch self {
        case .success: return DSColor.success
        case .warning: return DSColor.warning
        case .error: return DSColor.error
        }
    }
}
