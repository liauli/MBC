import MBCDesignSystem
import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: StationViewModel
    @State private var name = ""
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: DSSpacing.lg) {
                content
            }
            .padding()
            .navigationTitle(getString("register.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(getString("common.close")) { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .cardBlank:
            formSection
        case let .cardExists(card):
            existingCardSection(card)
        case let .registerSuccess(card):
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
        NFCPromptView(icon: "📝", text: getString("register.scan.prompt"), color: DSColor.primary)
        Button(getString("register.scan.button")) { viewModel.scanForRegister() }
            .buttonStyle(DSButtonStyle(.primary))
    }

    @ViewBuilder
    private var formSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(getString("register.name.label"))
                .font(DSFont.caption)
                .foregroundColor(DSColor.textSecondary)
            TextField(getString("register.name.placeholder"), text: $name)
                .textFieldStyle(.roundedBorder)
                .font(DSFont.body)
            Text(getString("register.name.hint"))
                .font(DSFont.caption)
                .foregroundColor(DSColor.textSecondary)
        }
        Button(getString("register.submit")) { viewModel.register(name: name) }
            .buttonStyle(DSButtonStyle(.primary))
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    @ViewBuilder
    private func existingCardSection(_ card: MemberCard) -> some View {
        ResultBanner(icon: "⚠️", title: getString("register.exists"), subtitle: card.identity.name, isSuccess: false)
        formSection
    }

    @ViewBuilder
    private func successSection(_ card: MemberCard) -> some View {
        ResultBanner(
            icon: "✅",
            title: getString("register.success"),
            subtitle: "Kartu terdaftar atas nama:\n\(card.identity.name)",
            isSuccess: true
        )
        InfoCard {
            InfoRow(label: "ID Anggota", value: card.identity.memberID)
            InfoRow(label: "Saldo", value: "Rp 0")
        }
        Button(getString("register.again")) { viewModel.reset(); name = "" }
            .buttonStyle(DSButtonStyle(.primary))
    }

    @ViewBuilder
    private func errorSection(_ message: String) -> some View {
        ResultBanner(icon: "❌", title: "Gagal", subtitle: message, isSuccess: false)
        Button(getString("common.retry")) { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.primary))
    }
}
