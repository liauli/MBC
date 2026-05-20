import SwiftUI

public struct NFCPromptView: View {
    private let icon: String
    private let text: String
    private let color: Color
    private let isScanning: Bool

    public init(icon: String, text: String, color: Color, isScanning: Bool = false) {
        self.icon = icon
        self.text = text
        self.color = color
        self.isScanning = isScanning
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 80, height: 80)
                .overlay(Text(icon).font(.system(size: 36)))
                .scaleEffect(isScanning ? 1.08 : 1.0)
                .animation(
                    .easeInOut(duration: 1).repeatForever(autoreverses: true),
                    value: isScanning
                )

            Text(text)
                .font(DSFont.body)
                .foregroundColor(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, DSSpacing.xl)
    }
}
