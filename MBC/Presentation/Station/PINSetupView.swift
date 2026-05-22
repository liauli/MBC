import MBCDesignSystem
import SwiftUI

struct PINSetupView: View {
    @ObservedObject var viewModel: PINViewModel
    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var isConfirming = false
    @State private var mismatchError = false

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            headerSection
            PINDotsView(count: currentCount)
            errorText
            PINPadView(onDigit: handleDigit, onDelete: handleDelete)
        }
        .padding()
    }

    @ViewBuilder
    private var headerSection: some View {
        Text("🔐").font(.system(size: 48))
        Text(isConfirming ? getString("pin.confirm") : getString("pin.create"))
            .font(DSFont.title)
            .foregroundColor(DSColor.textPrimary)
        Text(getString("pin.subtitle"))
            .font(DSFont.caption)
            .foregroundColor(DSColor.textSecondary)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var errorText: some View {
        if mismatchError {
            Text(getString("pin.mismatch"))
                .font(DSFont.caption)
                .foregroundColor(DSColor.error)
        } else if case let .error(message) = viewModel.state {
            Text(message)
                .font(DSFont.caption)
                .foregroundColor(DSColor.error)
        }
    }

    private var currentCount: Int {
        isConfirming ? confirmPin.count : pin.count
    }

    private func handleDigit(_ digit: String) {
        if isConfirming {
            guard confirmPin.count < 4 else { return }
            confirmPin += digit
            if confirmPin.count == 4 {
                handleConfirmation()
            }
        } else {
            guard pin.count < 4 else { return }
            pin += digit
            if pin.count == 4 { isConfirming = true }
        }
    }

    private func handleDelete() {
        if isConfirming {
            confirmPin = String(confirmPin.dropLast())
        } else {
            pin = String(pin.dropLast())
        }
    }

    private func handleConfirmation() {
        if confirmPin == pin {
            viewModel.setup(pin)
        } else {
            mismatchError = true
            confirmPin = ""
            isConfirming = false
            pin = ""
        }
    }
}
