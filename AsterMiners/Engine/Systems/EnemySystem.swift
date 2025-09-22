import Foundation
import simd

struct EnemySystem: System {
    func update(world: inout World, input: InputStateActor) {
        guard let playerID = world.players.keys.first, let playerTransform = world.transforms[playerID] else { return }
        let playerPosition = playerTransform.position
        for (entity, var ai) in world.ai {
            guard var physics = world.physicsBodies[entity], var transform = world.transforms[entity] else { continue }
            let direction = playerPosition - transform.position
            let distance = simd_length(direction)
            let normalized = distance > 0 ? direction / distance : SIMD3<Float>(repeating: 0)
            switch ai.behavior {
            case .swarm:
                physics.velocity += normalized * 0.4
            case .burrow:
                physics.velocity += normalized * 0.2
                if distance < 2 { physics.velocity *= -2 }
            case .spit:
                if distance > 6 { physics.velocity += normalized * 0.1 }
            case .shield:
                physics.velocity += normalized * 0.15
            case .boss:
                physics.velocity += normalized * 0.5
            }
            transform.position += physics.velocity * Float(GameTime.fixedTimeStep)
            physics.velocity *= 0.92
            world.physicsBodies[entity] = physics
            world.transforms[entity] = transform
            world.ai[entity] = ai
        }
    }
}
