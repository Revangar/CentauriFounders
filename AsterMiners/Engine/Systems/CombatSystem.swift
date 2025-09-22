import Foundation
import simd

final class CombatSystem: System {
    private var projectileSpeed: Float = 24

    func update(world: inout World, input: InputStateActor) {
        for (entity, var combat) in world.combat {
            combat.cooldown -= Float(GameTime.fixedTimeStep)
            if combat.cooldown <= 0 {
                fire(from: entity, combat: combat, world: &world)
                combat.cooldown = 1.0 / combat.fireRate
            }
            world.combat[entity] = combat
        }
    }

    private func fire(from entity: EntityID, combat: CombatComponent, world: inout World) {
        guard let origin = world.transforms[entity]?.position else { return }
        let projectile = world.createEntity()
        var color = SIMD4<Float>(1, 1, 1, 1)
        switch combat.weapon {
        case .beam:
            color = SIMD4<Float>(0.6, 1.0, 1.0, 1.0)
        case .shotgun:
            color = SIMD4<Float>(1.0, 0.6, 0.4, 1.0)
        case .orbital:
            color = SIMD4<Float>(0.8, 0.7, 1.0, 1.0)
        case .drone:
            color = SIMD4<Float>(0.7, 0.7, 0.7, 1.0)
        }
        let direction = SIMD3<Float>(0, 1, 0)
        world.setTransform(.init(position: origin + direction, rotation: 0, scale: SIMD3<Float>(repeating: 0.5)), for: projectile)
        world.setPhysics(.init(velocity: direction * projectileSpeed, acceleration: SIMD3<Float>(repeating: 0)), for: projectile)
        world.setRender(.init(mesh: .projectile, color: color, emissive: 1.5), for: projectile)
        world.setCollectible(.init(kind: .ore, value: 0), for: projectile)
    }
}
