import MBCDesignSystem
import SwiftUI

struct ScoutView: View {
    @StateObject private var viewModel = ViewModelProvider.instance.provideScoutViewModel()

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            mainContent
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Scout")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.state {
        case let .success(card):
            cardDetailSection(card)
        case let .error(message):
            errorSection(message)
        default:
            readySection
        }
    }

    @ViewBuilder
    private var readySection: some View {
        NFCPromptView(
            icon: "👁",
            text: "Tempelkan kartu\nuntuk melihat info",
            color: DSColor.textSecondary,
            isScanning: viewModel.state == .scanning
        )
        Button(getString("scout.scan.button")) { viewModel.scan() }
            .buttonStyle(DSButtonStyle(.primary))
            .disabled(viewModel.state == .scanning)
    }

    private func cardDetailSection(_ card: MemberCard) -> some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                memberGradientCard(card)
                balanceCard(card)
                transactionCard(card)
                Button(getString("scout.scan.again")) { viewModel.reset() }
                    .buttonStyle(DSButtonStyle(.outline))
            }
        }
    }

    private func memberGradientCard(_ card: MemberCard) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(card.identity.memberID)
                .font(DSFont.caption)
                .foregroundColor(DSColor.textDisable)
            Text(card.identity.name)
                .font(DSFont.title)
                .foregroundColor(.white)
            statusBadge(card)
        }
        .padding(DSSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColor.brandGradient)
        .cornerRadius(DSRadius.lg)
    }

    @ViewBuilder
    private func statusBadge(_ card: MemberCard) -> some View {
        switch card.visitState {
        case .idle:
            DSBadge("○ Tidak aktif", variant: .warning)
        case let .checkedIn(time, _):
            HStack(spacing: DSSpacing.xs) {
                DSBadge("● Di dalam", variant: .success)
                Text("Masuk: \(time.shortTimeFormatted)")
                    .font(DSFont.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private func balanceCard(_ card: MemberCard) -> some View {
        VStack {
            Text(getString("scout.balance"))
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

    private func transactionCard(_ card: MemberCard) -> some View {
        InfoCard {
            Text("📋 Riwayat Terakhir").font(DSFont.button)
            if card.transactions.isEmpty {
                Text(getString("scout.no.transactions"))
                    .font(DSFont.caption)
                    .foregroundColor(DSColor.textSecondary)
            } else {
                ForEach(card.transactions.reversed(), id: \.timestamp) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }

    @ViewBuilder
    private func errorSection(_ message: String) -> some View {
        ResultBanner(icon: "❌", title: "Gagal", subtitle: message, isSuccess: false)
        Button("Coba Lagi") { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.outline))
    }
}
