import MBCDesignSystem
import SwiftUI

struct RoleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Text(icon).font(.system(size: 40))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSFont.button)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(DSFont.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(DSSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DSRadius.lg)
    }
}
