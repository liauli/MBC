import MBCDesignSystem
import SwiftUI

struct ChangePINView: View {
    @StateObject private var viewModel = ViewModelProvider.instance.providePINViewModel()
    @State private var currentPIN = ""
    @State private var newPIN = ""
    @State private var step = 0
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: DSSpacing.lg) {
                headerSection
                PINDotsView(count: currentCount)
                statusText
                PINPadView(onDigit: handleDigit, onDelete: handleDelete)
            }
            .padding()
            .navigationTitle(getString("pin.change"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(getString("common.close")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        Text("🔑").font(.system(size: 48))
        Text(step == 0 ? getString("pin.old") : getString("pin.new"))
            .font(DSFont.title)
            .foregroundColor(DSColor.textPrimary)
    }

    @ViewBuilder
    private var statusText: some View {
        if case .pinChanged = viewModel.state {
            Text("PIN berhasil diubah ✓")
                .font(DSFont.body)
                .foregroundColor(DSColor.success)
        }
        if case let .error(message) = viewModel.state {
            Text(message)
                .font(DSFont.caption)
                .foregroundColor(DSColor.error)
        }
    }

    private var currentCount: Int {
        step == 0 ? currentPIN.count : newPIN.count
    }

    private func handleDigit(_ digit: String) {
        if step == 0 {
            guard currentPIN.count < 4 else { return }
            currentPIN += digit
            if currentPIN.count == 4 { step = 1 }
        } else {
            guard newPIN.count < 4 else { return }
            newPIN += digit
            if newPIN.count == 4 {
                viewModel.changePIN(current: currentPIN, new: newPIN)
            }
        }
    }

    private func handleDelete() {
        if step == 0 {
            currentPIN = String(currentPIN.dropLast())
        } else {
            newPIN = String(newPIN.dropLast())
        }
    }
}
