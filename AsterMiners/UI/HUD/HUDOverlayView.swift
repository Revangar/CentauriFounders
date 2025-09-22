import UIKit
import simd

protocol HUDOverlayViewDelegate: AnyObject {
    func hudRequestedPause()
    func hudRequestedExtraction()
    func hudRequestedDebug()
}

final class HUDOverlayView: UIView {
    private let simulation: SimulationCoordinator
    weak var delegate: HUDOverlayViewDelegate?
    private let movementStick = JoystickView()
    private let aimStick = JoystickView()
    private let dashButton = ActionButton(titleKey: "dash")
    private let mineButton = ActionButton(titleKey: "mine")
    private let interactButton = ActionButton(titleKey: "interact")
    private let pauseButton = UIButton(type: .system)
    private let extractButton = UIButton(type: .system)
    private let debugLabel = UILabel()
    private var displayLink: CADisplayLink?

    init(simulation: SimulationCoordinator) {
        self.simulation = simulation
        super.init(frame: .zero)
        configure()
        startDebugUpdates()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = .clear
        [movementStick, aimStick, dashButton, mineButton, interactButton, pauseButton, extractButton, debugLabel].forEach { addSubview($0) }

        movementStick.translatesAutoresizingMaskIntoConstraints = false
        aimStick.translatesAutoresizingMaskIntoConstraints = false
        dashButton.translatesAutoresizingMaskIntoConstraints = false
        mineButton.translatesAutoresizingMaskIntoConstraints = false
        interactButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        extractButton.translatesAutoresizingMaskIntoConstraints = false
        debugLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            movementStick.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            movementStick.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            movementStick.widthAnchor.constraint(equalToConstant: 140),
            movementStick.heightAnchor.constraint(equalToConstant: 140),

            aimStick.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            aimStick.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            aimStick.widthAnchor.constraint(equalToConstant: 140),
            aimStick.heightAnchor.constraint(equalToConstant: 140),

            dashButton.trailingAnchor.constraint(equalTo: aimStick.leadingAnchor, constant: -24),
            dashButton.bottomAnchor.constraint(equalTo: aimStick.bottomAnchor),
            dashButton.widthAnchor.constraint(equalToConstant: 96),
            dashButton.heightAnchor.constraint(equalToConstant: 96),

            mineButton.trailingAnchor.constraint(equalTo: dashButton.leadingAnchor, constant: -16),
            mineButton.bottomAnchor.constraint(equalTo: aimStick.bottomAnchor, constant: -110),
            mineButton.widthAnchor.constraint(equalToConstant: 96),
            mineButton.heightAnchor.constraint(equalToConstant: 96),

            interactButton.trailingAnchor.constraint(equalTo: aimStick.trailingAnchor),
            interactButton.bottomAnchor.constraint(equalTo: aimStick.topAnchor, constant: -16),
            interactButton.widthAnchor.constraint(equalToConstant: 96),
            interactButton.heightAnchor.constraint(equalToConstant: 96),

            pauseButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            pauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            extractButton.trailingAnchor.constraint(equalTo: pauseButton.trailingAnchor),
            extractButton.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 12),

            debugLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            debugLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8)
        ])

        debugLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        debugLabel.textColor = .white
        debugLabel.numberOfLines = 2
        let debugPress = UILongPressGestureRecognizer(target: self, action: #selector(showDebug))
        debugLabel.isUserInteractionEnabled = true
        debugLabel.addGestureRecognizer(debugPress)

        pauseButton.setTitle(NSLocalizedString("pause", comment: ""), for: .normal)
        pauseButton.setTitleColor(.white, for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)

        extractButton.setTitle(NSLocalizedString("extract", comment: ""), for: .normal)
        extractButton.setTitleColor(.systemYellow, for: .normal)
        extractButton.addTarget(self, action: #selector(extractTapped), for: .touchUpInside)

        movementStick.onChanged = { [weak self] vector in
            self?.simulation.updateInput { state in
                state.movementStick.isActive = true
                state.movementStick.vector = CGVector(dx: CGFloat(vector.x), dy: CGFloat(vector.y))
            }
        }
        movementStick.onEnded = { [weak self] in
            self?.simulation.updateInput { state in
                state.movementStick.isActive = false
                state.movementStick.vector = .zero
            }
        }

        aimStick.onChanged = { [weak self] vector in
            self?.simulation.updateInput { state in
                state.aimStick.isActive = true
                state.aimStick.vector = CGVector(dx: CGFloat(vector.x), dy: CGFloat(vector.y))
            }
        }
        aimStick.onEnded = { [weak self] in
            self?.simulation.updateInput { state in
                state.aimStick.isActive = false
                state.aimStick.vector = .zero
            }
        }

        dashButton.onTap = { [weak self] in self?.toggleFlag(\InputState.dashPressed) }
        mineButton.onTap = { [weak self] in self?.toggleFlag(\InputState.minePressed) }
        interactButton.onTap = { [weak self] in self?.toggleFlag(\InputState.interactPressed) }

        LocalizationService.shared.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateLocalizedStrings()
            }
        }
        updateLocalizedStrings()
    }

    private func toggleFlag(_ keyPath: WritableKeyPath<InputState, Bool>) {
        simulation.updateInput { $0[keyPath: keyPath] = true }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulation.updateInput { $0[keyPath: keyPath] = false }
        }
    }

    private func startDebugUpdates() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDebug))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateDebug() {
        let metrics = simulation.metricsSnapshot()
        let fps = Int(1.0 / max(0.0001, metrics.frameTime))
        debugLabel.text = "FPS: \(fps)\nSeed: #\(metrics.seed)"
    }

    @objc private func pauseTapped() {
        delegate?.hudRequestedPause()
    }

    @objc private func extractTapped() {
        delegate?.hudRequestedExtraction()
    }

    @objc private func showDebug() {
        delegate?.hudRequestedDebug()
    }

    private func updateLocalizedStrings() {
        pauseButton.setTitle(NSLocalizedString("pause", comment: ""), for: .normal)
        extractButton.setTitle(NSLocalizedString("extract", comment: ""), for: .normal)
        dashButton.refresh()
        mineButton.refresh()
        interactButton.refresh()
    }
}

private final class JoystickView: UIView {
    var onChanged: ((SIMD2<Float>) -> Void)?
    var onEnded: (() -> Void)?
    private let knob = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 70
        knob.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        knob.layer.cornerRadius = 30
        addSubview(knob)
        knob.frame = CGRect(x: bounds.midX - 30, y: bounds.midY - 30, width: 60, height: 60)
        knob.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let vector = SIMD2<Float>(Float((location.x - center.x) / (bounds.width / 2)), Float((location.y - center.y) / (bounds.height / 2)))
        let clamped = SIMD2<Float>(max(-1, min(1, vector.x)), max(-1, min(1, vector.y)))
        knob.center = CGPoint(x: center.x + CGFloat(clamped.x) * bounds.width / 3, y: center.y + CGFloat(clamped.y) * bounds.height / 3)
        onChanged?(clamped)
        if recognizer.state == .ended || recognizer.state == .cancelled {
            knob.center = center
            onEnded?()
        }
    }
}

private final class ActionButton: UIButton {
    var onTap: (() -> Void)?
    private let titleKey: String

    init(titleKey: String) {
        super.init(frame: .zero)
        self.titleKey = titleKey
        setTitle(LocalizationService.shared.localized(titleKey), for: .normal)
        backgroundColor = UIColor.systemTeal.withAlphaComponent(0.7)
        layer.cornerRadius = 48
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addTarget(self, action: #selector(tap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func tap() {
        onTap?()
    }

    func refresh() {
        setTitle(LocalizationService.shared.localized(titleKey), for: .normal)
    }
}
