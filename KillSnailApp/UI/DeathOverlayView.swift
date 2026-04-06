import AppKit

final class DeathOverlayView: NSView {
    var onReset: (() -> Void)?

    private let titleLabel = NSTextField(labelWithString: "YOU DEAD")
    private let subtitleLabel = NSTextField(labelWithString: "달팽이가 결국 마우스를 따라잡았습니다.")
    private let earnedMoneyCard = NSView(frame: .zero)
    private let earnedMoneyTitleLabel = NSTextField(labelWithString: "총 획득 금액")
    private let earnedMoneyValueLabel = NSTextField(labelWithString: "₩0")
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

        earnedMoneyCard.translatesAutoresizingMaskIntoConstraints = false
        earnedMoneyCard.wantsLayer = true
        earnedMoneyCard.layer?.backgroundColor = PixelSnailTheme.iconInset.withAlphaComponent(0.96).cgColor
        earnedMoneyCard.layer?.borderColor = PixelSnailTheme.outline.cgColor
        earnedMoneyCard.layer?.borderWidth = 3
        earnedMoneyCard.layer?.cornerRadius = 18
        earnedMoneyCard.layer?.shadowColor = PixelSnailTheme.outline.withAlphaComponent(0.35).cgColor
        earnedMoneyCard.layer?.shadowOpacity = 1
        earnedMoneyCard.layer?.shadowRadius = 18
        earnedMoneyCard.layer?.shadowOffset = CGSize(width: 0, height: -10)

        earnedMoneyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        earnedMoneyTitleLabel.textColor = PixelSnailTheme.shellShade
        earnedMoneyTitleLabel.font = .systemFont(ofSize: 16, weight: .heavy)
        earnedMoneyTitleLabel.alignment = .center

        earnedMoneyValueLabel.translatesAutoresizingMaskIntoConstraints = false
        earnedMoneyValueLabel.textColor = PixelSnailTheme.outline
        earnedMoneyValueLabel.font = .monospacedDigitSystemFont(ofSize: 34, weight: .black)
        earnedMoneyValueLabel.alignment = .center

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.bezelStyle = .rounded
        resetButton.font = .systemFont(ofSize: 18, weight: .bold)
        resetButton.target = self
        resetButton.action = #selector(handleReset)

        [earnedMoneyTitleLabel, earnedMoneyValueLabel].forEach(earnedMoneyCard.addSubview)
        [titleLabel, subtitleLabel, earnedMoneyCard, resetButton].forEach(addSubview)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -76),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            earnedMoneyCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 22),
            earnedMoneyCard.centerXAnchor.constraint(equalTo: centerXAnchor),
            earnedMoneyCard.widthAnchor.constraint(greaterThanOrEqualToConstant: 320),
            earnedMoneyCard.heightAnchor.constraint(equalToConstant: 110),

            earnedMoneyTitleLabel.topAnchor.constraint(equalTo: earnedMoneyCard.topAnchor, constant: 18),
            earnedMoneyTitleLabel.leadingAnchor.constraint(equalTo: earnedMoneyCard.leadingAnchor, constant: 24),
            earnedMoneyTitleLabel.trailingAnchor.constraint(equalTo: earnedMoneyCard.trailingAnchor, constant: -24),

            earnedMoneyValueLabel.topAnchor.constraint(equalTo: earnedMoneyTitleLabel.bottomAnchor, constant: 8),
            earnedMoneyValueLabel.leadingAnchor.constraint(equalTo: earnedMoneyCard.leadingAnchor, constant: 24),
            earnedMoneyValueLabel.trailingAnchor.constraint(equalTo: earnedMoneyCard.trailingAnchor, constant: -24),

            resetButton.topAnchor.constraint(equalTo: earnedMoneyCard.bottomAnchor, constant: 28),
            resetButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            resetButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
            resetButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func update(scale: Double, earnedMoney: String) {
        titleLabel.layer?.removeAllAnimations()
        titleLabel.wantsLayer = true
        titleLabel.layer?.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
        earnedMoneyValueLabel.stringValue = earnedMoney
    }

    @objc private func handleReset() {
        onReset?()
    }
}
