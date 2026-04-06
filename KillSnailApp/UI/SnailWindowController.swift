import AppKit
import KillSnailCore

final class SnailWindowController: NSWindowController {
    private let snailView = SnailView(frame: NSRect(x: 0, y: 0, width: 56, height: 56))
    private let moneyHUDView = MoneyHUDView(frame: NSRect(x: 0, y: 0, width: 220, height: 58))
    private let moneyHUDWindow: NSPanel

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

        moneyHUDWindow = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 220, height: 58),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        moneyHUDWindow.isFloatingPanel = true
        moneyHUDWindow.level = .floating
        moneyHUDWindow.backgroundColor = .clear
        moneyHUDWindow.isOpaque = false
        moneyHUDWindow.hasShadow = false
        moneyHUDWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        moneyHUDWindow.ignoresMouseEvents = true
        moneyHUDWindow.contentView = moneyHUDView

        super.init(window: panel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func show(position: DesktopPoint, size: Double, on screen: NSScreen?) {
        guard let window else { return }
        let frame = NSRect(x: position.x - (size / 2), y: position.y - (size / 2), width: size, height: size)
        window.setFrame(frame, display: true)
        window.orderFrontRegardless()

        positionMoneyHUD(on: screen)
        moneyHUDWindow.orderFrontRegardless()
    }

    func hide() {
        window?.orderOut(nil)
        moneyHUDWindow.orderOut(nil)
    }

    func hideMoneyHUD() {
        moneyHUDWindow.orderOut(nil)
    }

    func update(isPaused: Bool, facing: PixelSnailFacing, earnedMoney: String, on screen: NSScreen?) {
        snailView.update(isPaused: isPaused, facing: facing)
        moneyHUDView.update(earnedMoney: earnedMoney, isPaused: isPaused)
        positionMoneyHUD(on: screen)
    }

    private func positionMoneyHUD(on screen: NSScreen?) {
        guard let screen else { return }

        let size = moneyHUDView.measuredSize
        let visibleFrame = screen.visibleFrame
        let origin = NSPoint(
            x: visibleFrame.midX - (size.width / 2),
            y: visibleFrame.maxY - size.height - 18
        )

        moneyHUDWindow.setContentSize(size)
        moneyHUDWindow.setFrameOrigin(origin)
    }
}

private final class MoneyHUDView: NSView {
    private let activeIcon = PixelSnailArt.shared.makeStatusImage(pointSize: 20, isPaused: false)
    private let pausedIcon = PixelSnailArt.shared.makeStatusImage(pointSize: 20, isPaused: true)
    private let iconView = NSImageView(frame: .zero)
    private let titleLabel = NSTextField(labelWithString: "생존 수당")
    private let amountLabel = NSTextField(labelWithString: "₩0")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.backgroundColor = PixelSnailTheme.iconInset.withAlphaComponent(0.96).cgColor
        layer?.borderColor = PixelSnailTheme.outline.cgColor
        layer?.borderWidth = 3
        layer?.cornerRadius = 16
        layer?.shadowColor = PixelSnailTheme.outline.withAlphaComponent(0.24).cgColor
        layer?.shadowOpacity = 1
        layer?.shadowRadius = 14
        layer?.shadowOffset = CGSize(width: 0, height: -6)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = activeIcon

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = PixelSnailTheme.shellShade
        titleLabel.font = .systemFont(ofSize: 11, weight: .heavy)

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textColor = PixelSnailTheme.outline
        amountLabel.font = .monospacedDigitSystemFont(ofSize: 18, weight: .black)

        [iconView, titleLabel, amountLabel].forEach(addSubview)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 58),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 200),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            amountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    var measuredSize: NSSize {
        layoutSubtreeIfNeeded()
        let amountWidth = amountLabel.intrinsicContentSize.width
        let titleWidth = titleLabel.intrinsicContentSize.width
        let contentWidth = max(amountWidth, titleWidth)
        return NSSize(width: max(200, ceil(contentWidth + 60)), height: 58)
    }

    func update(earnedMoney: String, isPaused: Bool) {
        amountLabel.stringValue = earnedMoney
        alphaValue = isPaused ? 0.74 : 1.0
        iconView.image = isPaused ? pausedIcon : activeIcon
    }
}
