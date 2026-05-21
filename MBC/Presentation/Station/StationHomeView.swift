import MBCDesignSystem
import SwiftUI

struct StationHomeView: View {
    var body: some View {
        VStack(spacing: DSSpacing.md) {
            MenuCard(icon: "📝", title: "Daftar Anggota Baru", subtitle: "Registrasi kartu NFC baru") {}
            MenuCard(icon: "💰", title: "Isi Saldo", subtitle: "Top-up saldo anggota") {}
            MenuCard(icon: "🔑", title: "Ubah PIN", subtitle: "Ganti PIN akses Station") {}
            Spacer()
        }
        .padding()
        .background(DSColor.background.ignoresSafeArea())
    }
}
