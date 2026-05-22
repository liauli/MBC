import FirebaseCore
import SwiftUI

@main
struct MBCApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RoleSelectorView()
        }
    }
}
