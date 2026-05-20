import SwiftUI

public enum DSButtonVariant {
    case primary
    case secondary
    case outline

    var background: Color {
        switch self {
        case .primary: return DSColor.primary
        case .secondary: return DSColor.primaryLight
        case .outline: return .clear
        }
    }

    var foreground: Color {
        switch self {
        case .primary: return .white
        case .secondary: return DSColor.primary
        case .outline: return DSColor.primary
        }
    }

    var hasBorder: Bool {
        self == .outline
    }
}

public struct DSButtonStyle: ButtonStyle {
    private let variant: DSButtonVariant

    public init(_ variant: DSButtonVariant = .primary) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSFont.button)
            .frame(maxWidth: .infinity)
            .padding()
            .background(variant.background)
            .foregroundColor(variant.foreground)
            .cornerRadius(DSRadius.md)
            .overlay(
                variant.hasBorder
                    ? RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(DSColor.primary, lineWidth: 1.5)
                    : nil
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
