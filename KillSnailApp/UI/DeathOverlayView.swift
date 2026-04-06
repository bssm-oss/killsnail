import AppKit

final class DeathOverlayView: NSView {
    var onReset: (() -> Void)?

    private let titleLabel = NSTextField(labelWithString: "YOU DEAD")
    private let subtitleLabel = NSTextField(labelWithString: "달팽이가 결국 마우스를 따라잡았습니다.")
    private let resetButton = NSButton(title: "리셋", target: nil, action: nil)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.18).cgColor

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .systemRed
        titleLabel.font = .systemFont(ofSize: 92, weight: .black)
        titleLabel.alignment = .center

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = .white
        subtitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        subtitleLabel.alignment = .center

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.bezelStyle = .rounded
        resetButton.font = .systemFont(ofSize: 18, weight: .bold)
        resetButton.target = self
        resetButton.action = #selector(handleReset)

        [titleLabel, subtitleLabel, resetButton].forEach(addSubview)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            resetButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            resetButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            resetButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
            resetButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func update(scale: Double) {
        titleLabel.layer?.removeAllAnimations()
        titleLabel.wantsLayer = true
        titleLabel.layer?.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
    }

    @objc private func handleReset() {
        onReset?()
    }
}
