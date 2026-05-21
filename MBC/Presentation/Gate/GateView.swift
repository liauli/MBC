import MBCDesignSystem
import SwiftUI

struct GateView: View {
    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            NFCPromptView(
                icon: "🚪",
                text: "Tempelkan kartu anggota\nuntuk masuk",
                color: DSColor.primary
            )
            Button("Tap Kartu") {}
                .buttonStyle(DSButtonStyle(.primary))
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Gate")
        .navigationBarTitleDisplayMode(.inline)
    }
}
