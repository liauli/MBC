import MBCDesignSystem
import SwiftUI

struct TerminalView: View {
    @StateObject private var viewModel = ViewModelProvider.instance.provideTerminalViewModel()

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            lockHeader
            mainContent
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Terminal")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLocked)
    }

    private var lockHeader: some View {
        HStack {
            Spacer()
            Button(action: handleLockTap) {
                Image(systemName: viewModel.isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 22))
                    .foregroundColor(viewModel.isLocked ? DSColor.primary : DSColor.success)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                    viewModel.unlock()
                }
            )
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.state {
        case let .success(card, tariff):
            receiptSection(card, tariff)
        case let .error(message):
            errorSection(message)
        default:
            readySection
        }
    }

    @ViewBuilder
    private var readySection: some View {
        NFCPromptView(
            icon: "🚏",
            text: "Tempelkan kartu anggota\nuntuk keluar",
            color: DSColor.success,
            isScanning: viewModel.state == .scanning
        )
        Button("Tap Kartu") { viewModel.performCheckOut() }
            .buttonStyle(DSButtonStyle(.primary))
            .disabled(viewModel.state == .scanning)
    }

    @ViewBuilder
    private func receiptSection(_ card: MemberCard, _ tariff: TariffResult) -> some View {
        ResultBanner(
            icon: "✅",
            title: "Terima kasih, \(card.identity.name)!",
            subtitle: "Selamat jalan.",
            isSuccess: true
        )
        InfoCard {
            Text("🧾 Receipt").font(DSFont.button)
            InfoRow(label: "Durasi", value: formatDuration(tariff.duration))
            InfoRow(label: "Tarif (\(tariff.hours) jam × Rp 2.000)", value: "-Rp \(tariff.amount.currencyFormatted)")
            Divider()
            InfoRow(label: "Saldo sesudah", value: "Rp \(card.wallet.balance.currencyFormatted)")
        }
        Button("Selesai") { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.primary))
    }

    @ViewBuilder
    private func errorSection(_ message: String) -> some View {
        ResultBanner(icon: "❌", title: "Gagal", subtitle: message, isSuccess: false)
        Button("Kembali") { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.outline))
    }

    private func handleLockTap() {
        if !viewModel.isLocked {
            viewModel.lock()
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return "\(hours) jam \(minutes) menit"
    }
}
