import AppKit
import KillSnailCore

final class GameCoordinator {
    private let engine: SnailGameEngine
    private let snailWindowController = SnailWindowController()
    private let overlayWindowController = DeathOverlayWindowController()
    private let statusItemController = StatusItemController()

    private var timer: Timer?
    private var lastPhase: SnailPhase = .idle

    init(engine: SnailGameEngine = SnailGameEngine()) {
        self.engine = engine
    }

    func start() {
        statusItemController.onReset = { [weak self] in self?.reset() }
        statusItemController.onTogglePause = { [weak self] in self?.togglePause() }
        statusItemController.onQuit = {
            NSApplication.shared.terminate(nil)
        }

        overlayWindowController.onReset = { [weak self] in
            self?.reset()
        }

        let screen = activeScreen(for: currentCursorLocation())
        _ = engine.start(cursor: currentCursorLocation(), activeScreen: screen)
        apply(snapshot: engine.snapshot)

        timer = Timer.scheduledTimer(withTimeInterval: engine.configuration.updateInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }

        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        snailWindowController.hide()
        overlayWindowController.hide()
    }

    private func tick() {
        let cursor = currentCursorLocation()
        let screen = activeScreen(for: cursor)
        let snapshot = engine.update(cursor: cursor, activeScreen: screen, deltaTime: engine.configuration.updateInterval)
        apply(snapshot: snapshot)
    }

    private func reset() {
        let cursor = currentCursorLocation()
        let screen = activeScreen(for: cursor)
        let snapshot = engine.reset(cursor: cursor, activeScreen: screen)
        overlayWindowController.hide()
        apply(snapshot: snapshot)
    }

    private func togglePause() {
        let snapshot: GameSnapshot

        switch engine.snapshot.phase {
        case .paused:
            snapshot = engine.resume()
        case .dead:
            snapshot = engine.snapshot
        default:
            snapshot = engine.pause()
        }

        apply(snapshot: snapshot)
    }

    private func apply(snapshot: GameSnapshot) {
        statusItemController.update(for: snapshot.phase)
        let facing = snailFacing(for: snapshot)

        switch snapshot.phase {
        case .dead:
            snailWindowController.hide()
            let screen = screenMatching(snapshot.activeScreen) ?? NSScreen.main
            overlayWindowController.show(on: screen, scale: snapshot.deathScale)
            overlayWindowController.update(scale: snapshot.deathScale)

        case .paused:
            snailWindowController.show(position: snapshot.snailPosition, size: engine.configuration.spriteSize)
            snailWindowController.update(isPaused: true, facing: facing)
            overlayWindowController.hide()

        case .chasing, .idle:
            snailWindowController.show(position: snapshot.snailPosition, size: engine.configuration.spriteSize)
            snailWindowController.update(isPaused: false, facing: facing)
            overlayWindowController.hide()
        }

        if lastPhase != .dead, snapshot.phase == .dead {
            NSSound.beep()
        }

        lastPhase = snapshot.phase
    }

    private func currentCursorLocation() -> DesktopPoint {
        let point = NSEvent.mouseLocation
        return DesktopPoint(x: point.x, y: point.y)
    }

    private func activeScreen(for cursor: DesktopPoint) -> DesktopRect {
        let screens = NSScreen.screens
        let cursorPoint = NSPoint(x: cursor.x, y: cursor.y)
        let screen = screens.first(where: { $0.frame.contains(cursorPoint) }) ?? NSScreen.main ?? screens.first
        return screen.map { DesktopRect($0.visibleFrame) } ?? DesktopRect(minX: 0, minY: 0, width: 800, height: 600)
    }

    private func screenMatching(_ rect: DesktopRect) -> NSScreen? {
        NSScreen.screens.first(where: { DesktopRect($0.frame) == rect || DesktopRect($0.visibleFrame) == rect })
    }

    private func snailFacing(for snapshot: GameSnapshot) -> PixelSnailFacing {
        snapshot.cursorPosition.x < snapshot.snailPosition.x ? .left : .right
    }
}

private extension DesktopRect {
    init(_ rect: NSRect) {
        self.init(minX: rect.minX, minY: rect.minY, width: rect.width, height: rect.height)
    }
}
