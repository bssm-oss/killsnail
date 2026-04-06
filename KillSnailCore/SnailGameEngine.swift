import Foundation

public final class SnailGameEngine {
    public let configuration: SnailConfiguration

    public private(set) var snapshot: GameSnapshot

    private var deathElapsed: TimeInterval = 0

    public init(configuration: SnailConfiguration = SnailConfiguration()) {
        self.configuration = configuration
        let zero = DesktopPoint(x: 0, y: 0)
        let rect = DesktopRect(minX: 0, minY: 0, width: 1, height: 1)
        self.snapshot = GameSnapshot(
            phase: .idle,
            snailPosition: zero,
            cursorPosition: zero,
            activeScreen: rect,
            deathScale: 1
        )
    }

    @discardableResult
    public func start(cursor: DesktopPoint, activeScreen: DesktopRect) -> GameSnapshot {
        deathElapsed = 0
        snapshot = GameSnapshot(
            phase: .chasing,
            snailPosition: spawnPoint(oppositeTo: cursor, in: activeScreen),
            cursorPosition: cursor,
            activeScreen: activeScreen,
            deathScale: 1
        )
        return snapshot
    }

    @discardableResult
    public func pause() -> GameSnapshot {
        guard snapshot.phase == .chasing else { return snapshot }
        snapshot.phase = .paused
        return snapshot
    }

    @discardableResult
    public func resume() -> GameSnapshot {
        guard snapshot.phase == .paused else { return snapshot }
        snapshot.phase = .chasing
        return snapshot
    }

    @discardableResult
    public func reset(cursor: DesktopPoint, activeScreen: DesktopRect) -> GameSnapshot {
        start(cursor: cursor, activeScreen: activeScreen)
    }

    @discardableResult
    public func update(cursor: DesktopPoint, activeScreen: DesktopRect, deltaTime: TimeInterval) -> GameSnapshot {
        snapshot.cursorPosition = cursor

        if snapshot.activeScreen != activeScreen {
            snapshot.activeScreen = activeScreen

            if snapshot.phase == .chasing || snapshot.phase == .paused {
                snapshot.snailPosition = spawnPoint(oppositeTo: cursor, in: activeScreen)
            }
        }

        switch snapshot.phase {
        case .idle:
            return start(cursor: cursor, activeScreen: activeScreen)

        case .paused:
            return snapshot

        case .dead:
            deathElapsed += deltaTime
            let primary = sin(deathElapsed * configuration.deathPulseFrequency)
            let secondary = sin(deathElapsed * configuration.deathSecondaryFrequency)
            snapshot.deathScale = 1.0 + (primary * 0.2) + (secondary * 0.06)
            return snapshot

        case .chasing:
            let dx = cursor.x - snapshot.snailPosition.x
            let dy = cursor.y - snapshot.snailPosition.y
            let distance = hypot(dx, dy)

            if distance <= configuration.collisionRadius {
                deathElapsed = 0
                snapshot.phase = .dead
                snapshot.deathScale = 1.0
                return snapshot
            }

            guard distance > 0 else {
                return snapshot
            }

            let allowedStep = min(configuration.movementSpeed * deltaTime, distance)
            let nextPoint = DesktopPoint(
                x: snapshot.snailPosition.x + ((dx / distance) * allowedStep),
                y: snapshot.snailPosition.y + ((dy / distance) * allowedStep)
            )

            snapshot.snailPosition = activeScreen.clamped(nextPoint, inset: configuration.spawnInset)
            return snapshot
        }
    }

    public func spawnPoint(oppositeTo cursor: DesktopPoint, in screen: DesktopRect) -> DesktopPoint {
        let reflected = DesktopPoint(
            x: screen.minX + screen.maxX - cursor.x,
            y: screen.minY + screen.maxY - cursor.y
        )

        return screen.clamped(reflected, inset: configuration.spawnInset)
    }
}
