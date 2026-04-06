import Foundation

public struct SnailConfiguration: Equatable, Sendable {
    public let spriteSize: Double
    public let collisionRadius: Double
    public let movementSpeed: Double
    public let updateInterval: TimeInterval
    public let deathPulseFrequency: Double
    public let deathSecondaryFrequency: Double
    public let spawnInset: Double

    public init(
        spriteSize: Double = 56,
        collisionRadius: Double = 24,
        movementSpeed: Double = 18,
        updateInterval: TimeInterval = 0.05,
        deathPulseFrequency: Double = 6.2,
        deathSecondaryFrequency: Double = 14.0,
        spawnInset: Double = 42
    ) {
        self.spriteSize = spriteSize
        self.collisionRadius = collisionRadius
        self.movementSpeed = movementSpeed
        self.updateInterval = updateInterval
        self.deathPulseFrequency = deathPulseFrequency
        self.deathSecondaryFrequency = deathSecondaryFrequency
        self.spawnInset = spawnInset
    }
}
