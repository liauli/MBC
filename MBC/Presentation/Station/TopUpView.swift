import MBCDesignSystem
import SwiftUI

struct TopUpView: View {
    @ObservedObject var viewModel: StationViewModel
    @State private var selectedAmount = 0
    @State private var customAmount = ""
    @Environment(\.presentationMode) private var presentationMode

    private let presets = [10000, 20000, 50000, 100_000]

    var body: some View {
        NavigationView {
            VStack(spacing: DSSpacing.lg) {
                content
            }
            .padding()
            .navigationTitle("Isi Saldo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case let .topUpReady(card):
            amountSection(card)
        case let .topUpSuccess(card):
            successSection(card)
        case let .error(message):
            errorSection(message)
        case .loading:
            ProgressView("Memproses...")
        default:
            scanSection
        }
    }

    @ViewBuilder
    private var scanSection: some View {
        NFCPromptView(icon: "💰", text: "Tempelkan kartu anggota\nuntuk melihat saldo", color: DSColor.primary)
        Button("Scan Kartu") { viewModel.readForTopUp() }
            .buttonStyle(DSButtonStyle(.primary))
    }

    private func amountSection(_ card: MemberCard) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                balanceCard(card)
                presetGrid
                customInput
                confirmButton
            }
        }
    }

    private func balanceCard(_ card: MemberCard) -> some View {
        VStack {
            Text(card.identity.name)
                .font(DSFont.caption)
                .foregroundColor(DSColor.textSecondary)
            Text("Rp \(card.wallet.balance.currencyFormatted)")
                .font(DSFont.amount)
                .foregroundColor(DSColor.primary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(DSColor.surface)
        .cornerRadius(DSRadius.lg)
    }

    private var presetGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.sm) {
            ForEach(presets, id: \.self) { amount in
                Button {
                    selectedAmount = amount
                    customAmount = ""
                } label: {
                    Text("Rp \(amount.currencyFormatted)")
                        .font(DSFont.button)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedAmount == amount ? DSColor.primaryLight : DSColor.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .stroke(selectedAmount == amount ? DSColor.primary : DSColor.border, lineWidth: 1.5)
                        )
                        .cornerRadius(DSRadius.md)
                }
                .foregroundColor(selectedAmount == amount ? DSColor.primary : DSColor.textPrimary)
            }
        }
    }

    private var customInput: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Atau masukkan manual")
                .font(DSFont.caption)
                .foregroundColor(DSColor.textSecondary)
            TextField("Rp 0", text: $customAmount)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .onChange(of: customAmount) { _ in selectedAmount = 0 }
        }
    }

    private var confirmButton: some View {
        Button("Tempelkan Kartu untuk Top-Up") {
            viewModel.confirmTopUp(amount: effectiveAmount)
        }
        .buttonStyle(DSButtonStyle(.primary))
        .disabled(effectiveAmount <= 0)
    }

    @ViewBuilder
    private func successSection(_ card: MemberCard) -> some View {
        ResultBanner(
            icon: "✅",
            title: "Top-Up Berhasil!",
            subtitle: "Saldo baru: Rp \(card.wallet.balance.currencyFormatted)",
            isSuccess: true
        )
        Button("Selesai") { presentationMode.wrappedValue.dismiss() }
            .buttonStyle(DSButtonStyle(.primary))
    }

    @ViewBuilder
    private func errorSection(_ message: String) -> some View {
        ResultBanner(icon: "❌", title: "Gagal", subtitle: message, isSuccess: false)
        Button("Coba Lagi") { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.primary))
    }

    private var effectiveAmount: Int {
        selectedAmount > 0 ? selectedAmount : (Int(customAmount) ?? 0)
    }
}
