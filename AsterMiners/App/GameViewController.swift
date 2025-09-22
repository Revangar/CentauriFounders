import UIKit
import MetalKit

final class GameViewController: UIViewController, HUDOverlayViewDelegate {
    private var metalView: MTKView!
    private let renderer: Renderer
    private let simulation: SimulationCoordinator
    private let runConfiguration: RunConfiguration
    private var displayLink: CADisplayLink?

    init(runConfiguration: RunConfiguration) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal device required")
        }
        self.runConfiguration = runConfiguration
        let renderer = Renderer(device: device)
        self.renderer = renderer
        self.simulation = SimulationCoordinator(device: device, renderer: renderer, configuration: runConfiguration)
        super.init(nibName: nil, bundle: nil)
        title = LocalizationService.shared.localized("play")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureMetalView()
        configureHUD()
        simulation.start()
        startDisplayLink()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopDisplayLink()
        simulation.stop()
    }

    private func configureMetalView() {
        metalView = MTKView(frame: view.bounds, device: renderer.device)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.delegate = renderer
        metalView.framebufferOnly = false
        metalView.preferredFramesPerSecond = 60
        metalView.enableSetNeedsDisplay = false
        view.addSubview(metalView)
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metalView.topAnchor.constraint(equalTo: view.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureHUD() {
        let hud = HUDOverlayView(simulation: simulation)
        hud.delegate = self
        hud.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hud)
        NSLayoutConstraint.activate([
            hud.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hud.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hud.topAnchor.constraint(equalTo: view.topAnchor),
            hud.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func startDisplayLink() {
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .current, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ sender: CADisplayLink) {
        simulation.update()
    }

    func hudRequestedPause() {
        simulation.stop()
        let alert = UIAlertController(title: NSLocalizedString("pause_menu", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("resume", comment: ""), style: .default) { [weak self] _ in
            self?.simulation.start()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("exit_to_menu", comment: ""), style: .destructive) { _ in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate {
                delegate.returnToMenu()
            }
        })
        present(alert, animated: true)
    }

    func hudRequestedExtraction() {
        simulation.stop()
        let alert = UIAlertController(title: NSLocalizedString("extraction_prompt", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("extraction_now", comment: ""), style: .default) { [weak self] _ in
            self?.presentSummary(victorious: true)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("continue_run", comment: ""), style: .cancel) { [weak self] _ in
            self?.simulation.start()
        })
        present(alert, animated: true)
    }

    private func presentSummary(victorious: Bool) {
        let message = victorious ? NSLocalizedString("victory", comment: "") : NSLocalizedString("defeat", comment: "")
        let stats = NSLocalizedString("stats_title", comment: "")
        let combined = "\(stats)\n\(message)"
        let alert = UIAlertController(title: NSLocalizedString("stats_title", comment: ""), message: combined, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default) { _ in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate {
                delegate.returnToMenu()
            }
        })
        present(alert, animated: true)
    }

    func hudRequestedDebug() {
        let alert = UIAlertController(title: NSLocalizedString("debug_menu", comment: ""), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("grant_currency", comment: ""), style: .default) { [weak self] _ in
            self?.simulation.grantCurrency(amount: 500)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("spawn_boss", comment: ""), style: .default) { [weak self] _ in
            self?.simulation.spawnBossNow()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("reroll_upgrades", comment: ""), style: .default) { [weak self] _ in
            self?.simulation.rerollUpgrades()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
}
