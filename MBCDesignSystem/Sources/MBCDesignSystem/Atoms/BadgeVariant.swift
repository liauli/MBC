import SwiftUI

public enum BadgeVariant {
    case success
    case warning
    case error

    var background: Color {
        switch self {
        case .success: DSColor.successLight
        case .warning: DSColor.warningLight
        case .error: DSColor.errorLight
        }
    }

    var foreground: Color {
        switch self {
        case .success: DSColor.success
        case .warning: DSColor.warning
        case .error: DSColor.error
        }
    }
}
