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
            .navigationTitle("Daftar Anggota")
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
        NFCPromptView(icon: "📝", text: "Tempelkan kartu\nuntuk memeriksa status", color: DSColor.primary)
        Button("Scan Kartu") { viewModel.scanForRegister() }
            .buttonStyle(DSButtonStyle(.primary))
    }

    @ViewBuilder
    private var formSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Nama Anggota")
                .font(DSFont.caption)
                .foregroundColor(DSColor.textSecondary)
            TextField("Masukkan nama lengkap", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(DSFont.body)
            Text("Maks. 32 karakter")
                .font(DSFont.caption)
                .foregroundColor(DSColor.textSecondary)
        }
        Button("Daftarkan ke Kartu") { viewModel.register(name: name) }
            .buttonStyle(DSButtonStyle(.primary))
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    @ViewBuilder
    private func existingCardSection(_ card: MemberCard) -> some View {
        ResultBanner(icon: "⚠️", title: "Kartu Sudah Terdaftar", subtitle: card.identity.name, isSuccess: false)
        formSection
    }

    @ViewBuilder
    private func successSection(_ card: MemberCard) -> some View {
        ResultBanner(
            icon: "✅",
            title: "Berhasil!",
            subtitle: "Kartu terdaftar atas nama:\n\(card.identity.name)",
            isSuccess: true
        )
        InfoCard {
            InfoRow(label: "ID Anggota", value: card.identity.memberID)
            InfoRow(label: "Saldo", value: "Rp 0")
        }
        Button("Daftar Lagi") { viewModel.reset(); name = "" }
            .buttonStyle(DSButtonStyle(.primary))
    }

    @ViewBuilder
    private func errorSection(_ message: String) -> some View {
        ResultBanner(icon: "❌", title: "Gagal", subtitle: message, isSuccess: false)
        Button("Coba Lagi") { viewModel.reset() }
            .buttonStyle(DSButtonStyle(.primary))
    }
}
