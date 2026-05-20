import SwiftUI

public struct InfoRow: View {
    private let label: String
    private let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }

    public var body: some View {
        HStack {
            Text(label)
                .font(DSFont.caption)
                .foregroundColor(DSColor.textSecondary)
            Spacer()
            Text(value)
                .font(DSFont.caption)
                .fontWeight(.semibold)
                .foregroundColor(DSColor.textPrimary)
        }
        .padding(.vertical, 4)
    }
}
