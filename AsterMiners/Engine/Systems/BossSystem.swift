import Foundation
import simd

final class BossSystem: System {
    private var elapsed: TimeInterval = 0
    private let thresholds: [TimeInterval] = [300, 600]
    private var spawnedStages: Int = 0

    func update(world: inout World, input: InputStateActor) {
        elapsed += GameTime.fixedTimeStep
        if spawnedStages < thresholds.count, elapsed >= thresholds[spawnedStages] {
            spawnBoss(in: &world)
            spawnedStages += 1
        }
        for (entity, var boss) in world.bosses {
            guard var transform = world.transforms[entity], var physics = world.physicsBodies[entity] else { continue }
            boss.phase = Int(elapsed) % 3
            switch boss.phase {
            case 0:
                physics.velocity = SIMD3<Float>(Float(sin(elapsed)) * 2, 0, Float(cos(elapsed)) * 2)
            case 1:
                physics.velocity = SIMD3<Float>(Float(cos(elapsed)) * 3, 0, Float(sin(elapsed)) * 3)
            default:
                physics.velocity = SIMD3<Float>(0, 0, 0)
            }
            transform.position += physics.velocity * Float(GameTime.fixedTimeStep)
            world.transforms[entity] = transform
            world.physicsBodies[entity] = physics
            world.bosses[entity] = boss
        }
    }

    private func spawnBoss(in world: inout World) {
        let boss = world.createEntity()
        let position = SIMD3<Float>(0, 0, -12)
        world.setTransform(.init(position: position, rotation: 0, scale: SIMD3<Float>(repeating: 3.5)), for: boss)
        world.setPhysics(.init(velocity: .zero, acceleration: .zero), for: boss)
        world.setRender(.init(mesh: .boss, color: SIMD4<Float>(0.9, 0.5, 0.2, 1), emissive: 1.4), for: boss)
        world.setHealth(.init(current: 800, maximum: 800), for: boss)
        world.setAI(.init(behavior: .boss, target: world.players.keys.first))
        world.setBoss(.init(phase: 0, timers: [:]), for: boss)
    }
}
