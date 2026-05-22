import MBCDesignSystem
import SwiftUI

struct StationHomeView: View {
    @StateObject private var viewModel = ViewModelProvider.instance.provideStationViewModel()
    @State private var showRegister = false
    @State private var showTopUp = false

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            MenuCard(icon: "📝", title: "Daftar Anggota Baru", subtitle: "Registrasi kartu NFC baru") {
                showRegister = true
            }
            MenuCard(icon: "💰", title: "Isi Saldo", subtitle: "Top-up saldo anggota") {
                showTopUp = true
            }
            MenuCard(icon: "🔑", title: "Ubah PIN", subtitle: "Ganti PIN akses Station") {}
            Spacer()
        }
        .padding()
        .background(DSColor.background.ignoresSafeArea())
        .sheet(isPresented: $showRegister, onDismiss: { viewModel.reset() }, content: {
            RegisterView(viewModel: viewModel)
        })
        .sheet(isPresented: $showTopUp, onDismiss: { viewModel.reset() }, content: {
            TopUpView(viewModel: viewModel)
        })
    }
}
