import AppKit
import KillSnailCore

final class SnailWindowController: NSWindowController {
    private let snailView = SnailView(frame: NSRect(x: 0, y: 0, width: 56, height: 56))

    init() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 56, height: 56),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.ignoresMouseEvents = true
        panel.contentView = snailView
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true

        super.init(window: panel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func show(position: DesktopPoint, size: Double) {
        guard let window else { return }
        let frame = NSRect(x: position.x - (size / 2), y: position.y - (size / 2), width: size, height: size)
        window.setFrame(frame, display: true)
        window.orderFrontRegardless()
    }

    func hide() {
        window?.orderOut(nil)
    }

    func update(emoji: String, isPaused: Bool) {
        snailView.update(emoji: emoji, isPaused: isPaused)
    }
}
