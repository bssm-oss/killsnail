import Foundation

public struct DesktopPoint: Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct DesktopRect: Equatable, Sendable {
    public var minX: Double
    public var minY: Double
    public var width: Double
    public var height: Double

    public init(minX: Double, minY: Double, width: Double, height: Double) {
        self.minX = minX
        self.minY = minY
        self.width = width
        self.height = height
    }

    public var maxX: Double { minX + width }
    public var maxY: Double { minY + height }
    public var midX: Double { minX + (width / 2) }
    public var midY: Double { minY + (height / 2) }

    public func contains(_ point: DesktopPoint) -> Bool {
        point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
    }

    public func clamped(_ point: DesktopPoint, inset: Double) -> DesktopPoint {
        DesktopPoint(
            x: min(max(point.x, minX + inset), maxX - inset),
            y: min(max(point.y, minY + inset), maxY - inset)
        )
    }
}

public enum SnailPhase: Equatable, Sendable {
    case idle
    case chasing
    case dead
    case paused
}

public struct GameSnapshot: Equatable, Sendable {
    public var phase: SnailPhase
    public var snailPosition: DesktopPoint
    public var cursorPosition: DesktopPoint
    public var activeScreen: DesktopRect
    public var deathScale: Double
    public var earnedMoney: Double

    public init(
        phase: SnailPhase,
        snailPosition: DesktopPoint,
        cursorPosition: DesktopPoint,
        activeScreen: DesktopRect,
        deathScale: Double,
        earnedMoney: Double
    ) {
        self.phase = phase
        self.snailPosition = snailPosition
        self.cursorPosition = cursorPosition
        self.activeScreen = activeScreen
        self.deathScale = deathScale
        self.earnedMoney = earnedMoney
    }
}
