import AppKit
import KillSnailCore

final class StatusItemController {
    var onReset: (() -> Void)?
    var onTogglePause: (() -> Void)?
    var onQuit: (() -> Void)?

    private let statusItem: NSStatusItem
    private let menu = NSMenu()
    private let stateItem = NSMenuItem(title: "상태: 준비 중", action: nil, keyEquivalent: "")
    private let pauseItem = NSMenuItem(title: "잠시 멈춤", action: #selector(togglePause), keyEquivalent: "p")
    private let resetItem = NSMenuItem(title: "리셋", action: #selector(reset), keyEquivalent: "r")

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🐌"
        statusItem.button?.font = .systemFont(ofSize: 18)

        stateItem.isEnabled = false
        menu.addItem(stateItem)
        menu.addItem(.separator())

        pauseItem.target = self
        resetItem.target = self

        menu.addItem(pauseItem)
        menu.addItem(resetItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "종료", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func update(for phase: SnailPhase) {
        switch phase {
        case .idle:
            stateItem.title = "상태: 준비 중"
            pauseItem.title = "잠시 멈춤"
        case .chasing:
            stateItem.title = "상태: 추격 중"
            pauseItem.title = "잠시 멈춤"
        case .paused:
            stateItem.title = "상태: 일시정지"
            pauseItem.title = "다시 시작"
        case .dead:
            stateItem.title = "상태: YOU DEAD"
            pauseItem.title = "다시 시작"
        }
    }

    @objc private func reset() {
        onReset?()
    }

    @objc private func togglePause() {
        onTogglePause?()
    }

    @objc private func quit() {
        onQuit?()
    }
}
