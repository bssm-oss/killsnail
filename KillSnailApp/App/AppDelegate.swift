import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var coordinator: GameCoordinator?

    func applicationDidFinishLaunching(_ notification: Notification) {
        coordinator = GameCoordinator()
        coordinator?.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        coordinator?.stop()
    }
}
