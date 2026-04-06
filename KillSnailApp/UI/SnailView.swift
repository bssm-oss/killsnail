import AppKit

final class SnailView: NSView {
    private var isPaused = false
    private var facing: PixelSnailFacing = .right

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }
        PixelSnailArt.shared.drawSprite(
            in: bounds.insetBy(dx: 2, dy: 2),
            facing: facing,
            alpha: isPaused ? 0.6 : 1.0,
            context: context
        )
    }

    func update(isPaused: Bool, facing: PixelSnailFacing) {
        self.isPaused = isPaused
        self.facing = facing
        needsDisplay = true
    }
}
