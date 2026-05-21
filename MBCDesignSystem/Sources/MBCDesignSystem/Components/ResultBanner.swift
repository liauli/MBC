import SwiftUI

public struct ResultBanner: View {
    private let icon: String
    private let title: String
    private let subtitle: String
    private let isSuccess: Bool

    public init(icon: String, title: String, subtitle: String, isSuccess: Bool) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isSuccess = isSuccess
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Text(icon).font(.system(size: 32))
            Text(title)
                .font(DSFont.title)
                .foregroundColor(DSColor.textPrimary)
            Text(subtitle)
                .font(DSFont.body)
                .foregroundColor(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DSSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(isSuccess ? DSColor.successLight : DSColor.errorLight)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(
                    isSuccess ? DSColor.success.opacity(0.2) : DSColor.error.opacity(0.2),
                    lineWidth: 1
                )
        )
        .cornerRadius(DSRadius.lg)
    }
}
