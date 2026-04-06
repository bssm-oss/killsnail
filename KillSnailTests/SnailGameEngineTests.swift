import XCTest
@testable import KillSnailCore

final class SnailGameEngineTests: XCTestCase {
    func testChasingAccumulatesEarnedMoneyFromDeltaTime() {
        let configuration = SnailConfiguration(movementSpeed: 20, earningsPerSecond: 100_000_000)
        let engine = SnailGameEngine(configuration: configuration)
        let screen = DesktopRect(minX: 0, minY: 0, width: 1000, height: 800)
        let cursor = DesktopPoint(x: 950, y: 750)

        let startSnapshot = engine.start(cursor: cursor, activeScreen: screen)
        XCTAssertEqual(startSnapshot.earnedMoney, 0, accuracy: 0.0001)

        let firstUpdate = engine.update(cursor: cursor, activeScreen: screen, deltaTime: 0.5)
        XCTAssertEqual(firstUpdate.earnedMoney, 50_000_000, accuracy: 0.0001)

        let secondUpdate = engine.update(cursor: cursor, activeScreen: screen, deltaTime: 0.25)
        XCTAssertEqual(secondUpdate.earnedMoney, 75_000_000, accuracy: 0.0001)
    }

    func testPauseStopsEarnedMoneyUntilResume() {
        let configuration = SnailConfiguration(movementSpeed: 20, earningsPerSecond: 100_000_000)
        let engine = SnailGameEngine(configuration: configuration)
        let screen = DesktopRect(minX: 0, minY: 0, width: 1000, height: 800)
        let cursor = DesktopPoint(x: 950, y: 750)

        _ = engine.start(cursor: cursor, activeScreen: screen)
        let beforePause = engine.update(cursor: cursor, activeScreen: screen, deltaTime: 0.2)
        XCTAssertEqual(beforePause.earnedMoney, 20_000_000, accuracy: 0.0001)

        _ = engine.pause()
        let pausedSnapshot = engine.update(cursor: cursor, activeScreen: screen, deltaTime: 1.0)
        XCTAssertEqual(pausedSnapshot.phase, SnailPhase.paused)
        XCTAssertEqual(pausedSnapshot.earnedMoney, 20_000_000, accuracy: 0.0001)

        _ = engine.resume()
        let resumedSnapshot = engine.update(cursor: cursor, activeScreen: screen, deltaTime: 0.3)
        XCTAssertEqual(resumedSnapshot.phase, SnailPhase.chasing)
        XCTAssertEqual(resumedSnapshot.earnedMoney, 50_000_000, accuracy: 0.0001)
    }

    func testSpawnStartsOppositeCursorInsideScreen() {
        let engine = SnailGameEngine()
        let screen = DesktopRect(minX: 0, minY: 0, width: 1000, height: 800)
        let cursor = DesktopPoint(x: 120, y: 150)

        let snapshot = engine.start(cursor: cursor, activeScreen: screen)

        XCTAssertEqual(snapshot.phase, .chasing)
        XCTAssertEqual(snapshot.snailPosition, DesktopPoint(x: 880, y: 650))
    }

    func testUpdateMovesSnailTowardsCursorSlowly() {
        let configuration = SnailConfiguration(movementSpeed: 20, updateInterval: 0.5)
        let engine = SnailGameEngine(configuration: configuration)
        let screen = DesktopRect(minX: 0, minY: 0, width: 1000, height: 800)

        _ = engine.start(cursor: DesktopPoint(x: 950, y: 750), activeScreen: screen)

        let previous = engine.snapshot.snailPosition
        let snapshot = engine.update(cursor: DesktopPoint(x: 950, y: 750), activeScreen: screen, deltaTime: 0.5)

        XCTAssertEqual(snapshot.phase, .chasing)
        XCTAssertGreaterThan(snapshot.snailPosition.x, previous.x)
        XCTAssertGreaterThan(snapshot.snailPosition.y, previous.y)
    }

    func testCollisionTransitionsToDead() {
        let configuration = SnailConfiguration(collisionRadius: 30, earningsPerSecond: 100_000_000)
        let engine = SnailGameEngine(configuration: configuration)
        let screen = DesktopRect(minX: 0, minY: 0, width: 500, height: 400)

        _ = engine.start(cursor: DesktopPoint(x: 250, y: 200), activeScreen: screen)
        let position = engine.snapshot.snailPosition

        let snapshot = engine.update(cursor: position, activeScreen: screen, deltaTime: 0.05)

        XCTAssertEqual(snapshot.phase, .dead)
        XCTAssertEqual(snapshot.deathScale, 1.0)
        XCTAssertEqual(snapshot.earnedMoney, 5_000_000, accuracy: 0.0001)

        let frozenSnapshot = engine.update(cursor: position, activeScreen: screen, deltaTime: 1.0)
        XCTAssertEqual(frozenSnapshot.phase, .dead)
        XCTAssertEqual(frozenSnapshot.earnedMoney, 5_000_000, accuracy: 0.0001)
    }

    func testResetRespawnsOnCurrentScreen() {
        let configuration = SnailConfiguration(movementSpeed: 20, earningsPerSecond: 100_000_000)
        let engine = SnailGameEngine(configuration: configuration)
        let firstScreen = DesktopRect(minX: 0, minY: 0, width: 600, height: 400)
        let secondScreen = DesktopRect(minX: 600, minY: 0, width: 600, height: 400)

        _ = engine.start(cursor: DesktopPoint(x: 40, y: 40), activeScreen: firstScreen)
        _ = engine.update(cursor: DesktopPoint(x: 40, y: 40), activeScreen: firstScreen, deltaTime: 0.4)
        let resetSnapshot = engine.reset(cursor: DesktopPoint(x: 900, y: 120), activeScreen: secondScreen)

        XCTAssertEqual(resetSnapshot.phase, SnailPhase.chasing)
        XCTAssertEqual(resetSnapshot.activeScreen, secondScreen)
        XCTAssertTrue(secondScreen.contains(resetSnapshot.snailPosition))
        XCTAssertEqual(resetSnapshot.earnedMoney, 0, accuracy: 0.0001)
    }
}
