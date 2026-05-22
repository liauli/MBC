import MBCDesignSystem
import SwiftUI

struct StationHomeView: View {
    @StateObject private var viewModel = ViewModelProvider.instance.provideStationViewModel()
    @State private var showRegister = false
    @State private var showTopUp = false
    @State private var showChangePIN = false

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            MenuCard(icon: "📝", title: getString("station.register"), subtitle: getString("station.register.desc")) {
                showRegister = true
            }
            MenuCard(icon: "💰", title: getString("station.topup"), subtitle: getString("station.topup.desc")) {
                showTopUp = true
            }
            MenuCard(icon: "🔑", title: getString("station.changepin"), subtitle: getString("station.changepin.desc")) {
                showChangePIN = true
            }
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
        .sheet(isPresented: $showChangePIN) {
            ChangePINView()
        }
    }
}
