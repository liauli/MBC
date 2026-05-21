import SwiftUI

public struct PINPadView: View {
    private let onDigit: (String) -> Void
    private let onDelete: () -> Void

    public init(onDigit: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.onDigit = onDigit
        self.onDelete = onDelete
    }

    private let keys = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: DSSpacing.sm) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            if key == "⌫" { onDelete() }
                            else if !key.isEmpty { onDigit(key) }
                        } label: {
                            Text(key)
                                .font(DSFont.title)
                                .frame(width: 70, height: 70)
                                .background(key.isEmpty ? Color.clear : DSColor.surface)
                                .cornerRadius(35)
                                .shadow(
                                    color: key.isEmpty ? .clear : .black.opacity(0.04),
                                    radius: 2,
                                    y: 1
                                )
                        }
                        .disabled(key.isEmpty)
                        .foregroundColor(DSColor.textPrimary)
                    }
                }
            }
        }
    }
}
