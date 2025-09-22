import Foundation
import simd

final class SpawningSystem: System {
    private var spawnTimer: Float = 1
    private let configuration: RunConfiguration

    init(configuration: RunConfiguration) {
        self.configuration = configuration
    }

    func update(world: inout World, input: InputStateActor) {
        spawnTimer -= Float(GameTime.fixedTimeStep)
        if spawnTimer <= 0 {
            spawnWave(world: &world)
            spawnTimer = max(0.25, 2.0 - Float(configuration.difficulty) * 0.1)
        }
    }

    private func spawnWave(world: inout World) {
        let archetypes = ["swarmling", "burrower", "spitter", "shielder"]
        for name in archetypes {
            let entity = world.createEntity()
            let angle = Float.random(in: 0..<Float.pi * 2)
            let radius: Float = 12
            let position = SIMD3<Float>(cos(angle) * radius, 0, sin(angle) * radius)
            world.setTransform(.init(position: position, rotation: 0, scale: SIMD3<Float>(repeating: 1)), for: entity)
            world.setPhysics(.init(velocity: .zero, acceleration: .zero), for: entity)
            world.setRender(.init(mesh: mesh(for: name), color: color(for: name), emissive: 0.1), for: entity)
            world.setHealth(.init(current: 20, maximum: 20), for: entity)
            world.setAI(.init(behavior: behavior(for: name), target: world.players.keys.first))
            world.setEnemy(.init(archetype: name, spawnTime: Date().timeIntervalSince1970), for: entity)
        }
    }

    private func mesh(for archetype: String) -> MeshIdentifier {
        switch archetype {
        case "burrower": return .burrower
        case "spitter": return .spitter
        case "shielder": return .shielder
        default: return .swarmling
        }
    }

    private func color(for archetype: String) -> SIMD4<Float> {
        switch archetype {
        case "burrower": return SIMD4<Float>(0.5, 0.2, 0.6, 1)
        case "spitter": return SIMD4<Float>(0.2, 0.7, 0.3, 1)
        case "shielder": return SIMD4<Float>(0.3, 0.6, 1.0, 1)
        default: return SIMD4<Float>(0.8, 0.1, 0.1, 1)
        }
    }

    private func behavior(for archetype: String) -> AIComponent.Behavior {
        switch archetype {
        case "burrower": return .burrow
        case "spitter": return .spit
        case "shielder": return .shield
        default: return .swarm
        }
    }
}
