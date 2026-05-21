import SwiftUI

public struct PINDotsView: View {
    private let count: Int
    private let isError: Bool

    public init(count: Int, isError: Bool = false) {
        self.count = count
        self.isError = isError
    }

    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            ForEach(0 ..< 4, id: \.self) { i in
                Circle()
                    .fill(i < count ? fillColor : Color.clear)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(fillColor, lineWidth: 2))
            }
        }
    }

    private var fillColor: Color {
        isError ? DSColor.error : DSColor.secondary
    }
}
