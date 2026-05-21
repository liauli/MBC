import MBCDesignSystem
import SwiftUI

struct ScoutView: View {
    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            NFCPromptView(
                icon: "👁",
                text: "Tempelkan kartu\nuntuk melihat info",
                color: DSColor.textSecondary
            )
            Button("Scan Kartu") {}
                .buttonStyle(DSButtonStyle(.primary))
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Scout")
        .navigationBarTitleDisplayMode(.inline)
    }
}
