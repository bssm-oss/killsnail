import AppKit

enum PixelSnailTheme {
    static let outline = NSColor(snailHex: "#3C2B23")!
    static let shell = NSColor(snailHex: "#F48EA6")!
    static let shellShade = NSColor(snailHex: "#D96C85")!
    static let shellHighlight = NSColor(snailHex: "#FFD7E2")!
    static let body = NSColor(snailHex: "#8FD39A")!
    static let bodyLight = NSColor(snailHex: "#D9F6C8")!
    static let iconBackground = NSColor(snailHex: "#F8E7A1")!
    static let iconInset = NSColor(snailHex: "#FFF7D5")!
}

private extension NSColor {
    convenience init?(snailHex hex: String) {
        let normalized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        guard normalized.count == 6, let value = UInt64(normalized, radix: 16) else {
            return nil
        }

        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255,
            green: CGFloat((value & 0x00FF00) >> 8) / 255,
            blue: CGFloat(value & 0x0000FF) / 255,
            alpha: 1
        )
    }
}
