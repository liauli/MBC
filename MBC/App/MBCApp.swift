import SwiftUI
import UIKit

@main
struct MBCApp: App {
    init() {
        for family in UIFont.familyNames.sorted() {
            for name in UIFont.fontNames(forFamilyName: family) {
                if name.lowercased().contains("poppins") || name.lowercased().contains("batik") {
                    print("✅ FONT: \(name)")
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RoleSelectorView()
        }
    }
}
