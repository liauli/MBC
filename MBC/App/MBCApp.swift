import FirebaseCore
import SwiftUI

@main
struct MBCApp: App {
    init() {
        FirebaseApp.configure()
        RemoteConfigService().fetchAndActivate { _ in }
    }

    var body: some Scene {
        WindowGroup {
            RoleSelectorView()
                .preferredColorScheme(.light)
        }
    }
}
