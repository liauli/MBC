import MBCDesignSystem
import SwiftUI

struct TerminalView: View {
    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            NFCPromptView(
                icon: "🚏",
                text: "Tempelkan kartu anggota\nuntuk keluar",
                color: DSColor.success
            )
            Button("Tap Kartu") {}
                .buttonStyle(DSButtonStyle(.primary))
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Terminal")
        .navigationBarTitleDisplayMode(.inline)
    }
}
