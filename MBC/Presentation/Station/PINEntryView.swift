import MBCDesignSystem
import SwiftUI

struct PINEntryView: View {
    @ObservedObject var viewModel: PINViewModel
    @State private var pin = ""

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            headerSection
            PINDotsView(count: pin.count, isError: isError)
            errorText
            PINPadView(onDigit: handleDigit, onDelete: handleDelete)
        }
        .padding()
    }

    @ViewBuilder
    private var headerSection: some View {
        Text("🔒").font(.system(size: 48))
        Text(getString("pin.enter"))
            .font(DSFont.title)
            .foregroundColor(DSColor.textPrimary)
    }

    @ViewBuilder
    private var errorText: some View {
        switch viewModel.state {
        case let .wrongPIN(remaining):
            Text(getString("pin.wrong", remaining))
                .font(DSFont.caption)
                .foregroundColor(DSColor.error)
        case .locked:
            Text(getString("pin.locked"))
                .font(DSFont.caption)
                .foregroundColor(DSColor.error)
        default:
            EmptyView()
        }
    }

    private var isError: Bool {
        if case .wrongPIN = viewModel.state { return true }
        if case .locked = viewModel.state { return true }
        return false
    }

    private func handleDigit(_ digit: String) {
        guard pin.count < 4 else { return }
        pin += digit
        if pin.count == 4 {
            viewModel.verify(pin)
            pin = ""
        }
    }

    private func handleDelete() {
        pin = String(pin.dropLast())
    }
}
