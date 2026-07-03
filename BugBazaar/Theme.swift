import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum Theme {
    // stickerGreen/mangoOrange intentionally match the CSS named colors
    // 'blue' and 'green' used by the original React Native theme.
    static let stickerGreen = Color(hex: 0x0000FF)
    static let mangoOrange = Color(hex: 0x008000)
    static let mangoYellow = Color(hex: 0xFFD500)
    static let inkBlack = Color(hex: 0x080808)
    static let paperWhite = Color(hex: 0xFCFCFC)
    static let gray = Color(hex: 0x999999)
    static let lightGray = Color(hex: 0xF0F0F0)
    static let cardBg = Color(hex: 0xF4F4F4)
    static let priceGray = Color(hex: 0x444444)
    static let hotRed = Color(hex: 0xFF4444)
    static let rejectedRed = Color(hex: 0xFF6B6B)
    static let hairline = Color.black.opacity(0.05)
}

enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}

extension Font {
    /// Display font. The original app uses Fraunces 900; New York serif at
    /// black weight is the closest native equivalent.
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .serif)
    }

    /// Body font. The original app uses Courier on iOS.
    static func bodyFont(_ size: CGFloat, bold: Bool = false) -> Font {
        Font.custom("Courier", size: size).weight(bold ? .bold : .regular)
    }
}
