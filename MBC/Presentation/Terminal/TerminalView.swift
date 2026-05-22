import MBCDesignSystem
import SwiftUI

struct TerminalView: View {
    @StateObject private var viewModel = ViewModelProvider.instance.provideTerminalViewModel()
    @State private var showLockConfirm = false

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            topBar
            mainContent
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Terminal")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLocked)
        .alert(isPresented: $showLockConfirm) {
            Alert(
                title: Text("Kunci Layar?"),
                message: Text("Navigasi akan dinonaktifkan.\nTekan lama ikon kunci untuk membuka."),
                primaryButton: .destructive(Text("Kunci")) { viewModel.lock() },
                secondaryButton: .cancel(Text("Batal"))
            )
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            lockIcon
        }
    }

    @ViewBuilder
    private var lockIcon: some View {
        if viewModel.isLocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 22))
                .foregroundColor(DSColor.primary)
                .onLongPressGesture(minimumDuration: 1.0) {
                    viewModel.unlock()
                }
        } else {
            Image(systemName: "lock.open.fill")
                .font(.system(size: 22))
                .foregroundColor(DSColor.success)
                .onTapGesture {
                    showLockConfirm = true
                }
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
        Spacer()
        NFCPromptView(
            icon: "🚏",
            text: "Tempelkan kartu anggota\nuntuk keluar",
            color: DSColor.success,
            isScanning: viewModel.state == .scanning
        )
        Spacer()
        Button(getString("terminal.scan.button")) { viewModel.performCheckOut() }
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
        Button(getString("terminal.done")) { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.primary))
    }

    @ViewBuilder
    private func errorSection(_ message: String) -> some View {
        ResultBanner(icon: "❌", title: "Gagal", subtitle: message, isSuccess: false)
        Button(getString("common.back")) { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.outline))
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return "\(hours) jam \(minutes) menit"
    }
}
