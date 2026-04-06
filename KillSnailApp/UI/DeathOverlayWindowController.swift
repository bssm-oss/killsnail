import AppKit

final class DeathOverlayWindowController: NSWindowController {
    var onReset: (() -> Void)? {
        didSet {
            overlayView.onReset = onReset
        }
    }

    private let overlayView = DeathOverlayView(frame: .zero)

    init() {
        let panel = NSPanel(
            contentRect: NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        panel.contentView = overlayView

        super.init(window: panel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func show(on screen: NSScreen?, scale: Double) {
        guard let window else { return }
        if let screen {
            window.setFrame(screen.frame, display: true)
        }

        overlayView.update(scale: scale)
        window.orderFrontRegardless()
    }

    func update(scale: Double) {
        overlayView.update(scale: scale)
    }

    func hide() {
        window?.orderOut(nil)
    }
}
