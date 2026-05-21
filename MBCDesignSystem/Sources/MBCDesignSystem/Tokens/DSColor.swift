import SwiftUI

public enum DSColor {
    // MARK: - Primary (Telkomsel Red)

    public static let primary = Color(hex: 0xFF0025)
    public static let primaryHover = Color(hex: 0xFF3351)
    public static let primaryLight = Color(hex: 0xFFEBEE)

    // MARK: - Secondary (Navy)

    public static let secondary = Color(hex: 0x001A41)
    public static let secondaryLight = Color(hex: 0x334867)

    // MARK: - Semantic

    public static let success = Color(hex: 0x008E53)
    public static let successLight = Color(hex: 0xEDFCF0)
    public static let warning = Color(hex: 0xD9801F)
    public static let warningLight = Color(hex: 0xFEF3D4)
    public static let error = Color(hex: 0xBC1D42)
    public static let errorLight = Color(hex: 0xFDDDD4)
    public static let info = Color(hex: 0x0050AE)
    public static let infoLight = Color(hex: 0xE7F5FC)

    // MARK: - Neutral

    public static let background = Color(hex: 0xF5F6FA)
    public static let surface = Color.white
    public static let border = Color(hex: 0xCCCFD3)
    public static let divider = Color(hex: 0xE9E8ED)

    // MARK: - Text

    public static let textPrimary = Color(hex: 0x001A41)
    public static let textSecondary = Color(hex: 0x4E5764)
    public static let textDisable = Color(hex: 0xB3BAC6)

    // MARK: - Gradient

    public static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: 0x001A41), Color(hex: 0x0E336C)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
