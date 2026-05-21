import SwiftUI

public struct MenuCard: View {
    private let icon: String
    private let title: String
    private let subtitle: String
    private let action: () -> Void

    public init(icon: String, title: String, subtitle: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                Text(icon).font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DSFont.button)
                        .foregroundColor(DSColor.textPrimary)
                    Text(subtitle)
                        .font(DSFont.caption)
                        .foregroundColor(DSColor.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(DSColor.textDisable)
            }
            .padding()
            .background(DSColor.surface)
            .cornerRadius(DSRadius.lg)
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
    }
}
