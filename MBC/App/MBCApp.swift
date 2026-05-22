import SwiftUI

@main
struct MBCApp: App {
    var body: some Scene {
        WindowGroup {
            RoleSelectorView()
                .preferredColorScheme(.light)
        }
    }
}
