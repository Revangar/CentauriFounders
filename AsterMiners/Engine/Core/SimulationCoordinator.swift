import Foundation
import Metal
import simd

final class SimulationCoordinator {
    private var time = GameTime()
    private var lastTimestamp = Date()
    private(set) var world: World
    private let device: MTLDevice
    private let renderer: Renderer
    private let configuration: RunConfiguration
    private let input = InputStateActor()
    private var systems: [System]
    private var particleSystem: ParticleSystem
    private var audioSystem: AudioSystem
    private var paused: Bool = false

    init(device: MTLDevice, renderer: Renderer, configuration: RunConfiguration) {
        self.device = device
        self.renderer = renderer
        self.configuration = configuration
        let world = World()
        self.world = world
        let assetLoader = AssetLoader()
        UpgradeCatalog.shared.configure(with: assetLoader.loadUpgradeConfigs())
        var rng = RNGService(seed: configuration.seed)
        let runContext = RunContext(configuration: configuration, rng: rng)
        let movement = MovementSystem()
        let combat = CombatSystem()
        let spawning = SpawningSystem(configuration: configuration)
        let mining = MiningSystem()
        let upgrade = UpgradeSystem()
        let loot = LootSystem()
        let lighting = LightingSystem()
        let enemies = EnemySystem()
        let boss = BossSystem()
        self.particleSystem = ParticleSystem(device: device)
        self.audioSystem = AudioSystem()
        self.systems = [spawning, enemies, movement, combat, mining, loot, upgrade, lighting, boss]
        renderer.bind(world: world, particleSystem: particleSystem)
        let qualityLevel = (try? SaveService.shared.load().options.graphicsQuality) ?? 2
        applyQuality(level: qualityLevel)
        bootstrapWorld(context: runContext)
    }

    private func bootstrapWorld(context: RunContext) {
        ArenaGenerator.generate(in: &world, context: context)
        EntityFactory.populatePlayer(in: &world, context: context)
        renderer.setDebugMessage("Seed: \(context.configuration.seed)")
    }

    private func applyQuality(level: Int) {
        particleSystem.setQuality(level: level)
        renderer.setBloom(enabled: level > 0)
    }

    func start() {
        paused = false
        audioSystem.start()
    }

    func stop() {
        paused = true
        audioSystem.stop()
    }

    func update() {
        guard !paused else { return }
        let now = Date()
        let delta = now.timeIntervalSince(lastTimestamp)
        lastTimestamp = now
        time.advance(by: delta) { [weak self] in
            self?.step()
        }
        renderer.enqueueFrame(world: world, deltaTime: delta)
    }

    private func step() {
        systems.forEach { $0.update(world: &world, input: input) }
        particleSystem.update(world: &world, input: input)
        audioSystem.update(world: world)
    }
}

extension SimulationCoordinator {
    func updateInput(_ transform: @escaping (inout InputState) -> Void) {
        Task { await input.update(transform) }
    }

    func currentInput() async -> InputState {
        await input.snapshot()
    }
}

struct SimulationMetrics {
    var frameTime: TimeInterval
    var seed: UInt64
}

extension SimulationCoordinator {
    func metricsSnapshot() -> SimulationMetrics {
        SimulationMetrics(frameTime: renderer.metrics.frameTime, seed: configuration.seed)
    }
}

extension SimulationCoordinator {
    func spawnBossNow() {
        let boss = world.createEntity()
        let position = SIMD3<Float>(0, 0, -10)
        world.setTransform(.init(position: position, rotation: 0, scale: SIMD3<Float>(repeating: 3.5)), for: boss)
        world.setPhysics(.init(velocity: .zero, acceleration: .zero), for: boss)
        world.setRender(.init(mesh: .boss, color: SIMD4<Float>(0.95, 0.4, 0.1, 1), emissive: 1.2), for: boss)
        world.setHealth(.init(current: 600, maximum: 600), for: boss)
        world.setAI(.init(behavior: .boss, target: world.players.keys.first))
        world.setBoss(.init(phase: 0, timers: [:]), for: boss)
    }

    func grantCurrency(amount: Int) {
        guard var save = try? SaveService.shared.load() else { return }
        save.unlocks.currency += amount
        try? SaveService.shared.persist(save)
    }

    func rerollUpgrades() {
        guard let playerID = world.players.keys.first, var player = world.players[playerID] else { return }
        let draft = UpgradeCatalog.shared.randomDraft(for: player, count: 3)
        player.pendingUpgrades = draft
        world.players[playerID] = player
    }
}
