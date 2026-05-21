import SwiftUI

public struct InfoCard<Content: View>: View {
    @ViewBuilder private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColor.surface)
        .cornerRadius(DSRadius.lg)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
