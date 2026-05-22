import MBCDesignSystem
import SwiftUI

struct StationGateView: View {
    @StateObject private var pinViewModel = ViewModelProvider.instance.providePINViewModel()

    var body: some View {
        Group {
            if pinViewModel.state == .authenticated {
                StationHomeView()
            } else if pinViewModel.needsSetup {
                PINSetupView(viewModel: pinViewModel)
            } else {
                PINEntryView(viewModel: pinViewModel)
            }
        }
        .navigationTitle("Station")
        .navigationBarTitleDisplayMode(.inline)
    }
}
