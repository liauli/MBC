import SwiftUI

public struct DSBadge: View {
    private let text: String
    private let variant: BadgeVariant

    public init(_ text: String, variant: BadgeVariant) {
        self.text = text
        self.variant = variant
    }

    public var body: some View {
        Text(text)
            .font(DSFont.caption)
            .fontWeight(.medium)
            .foregroundColor(variant.foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(variant.background)
            .cornerRadius(DSRadius.md)
    }
}
