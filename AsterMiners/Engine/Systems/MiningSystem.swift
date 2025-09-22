import Foundation
import simd

struct MiningSystem: System {
    func update(world: inout World, input: InputStateActor) {
        for (entity, var crystal) in world.crystals {
            guard let transform = world.transforms[entity] else { continue }
            let heatLight = HeatLightComponent(heat: 4, light: 8)
            world.heatLights[entity] = heatLight
            crystal.remaining = max(0, crystal.remaining - 0.05)
            if crystal.remaining <= 0 {
                triggerBuff(crystal.buff, at: transform.position, world: &world)
                world.enqueueRemoval(entity)
            } else {
                world.crystals[entity] = crystal
            }
        }
    }

    private func triggerBuff(_ buff: CrystalComponent.BuffType, at position: SIMD3<Float>, world: inout World) {
        switch buff {
        case .slowField:
            for (entity, var physics) in world.physicsBodies {
                physics.velocity *= 0.5
                world.physicsBodies[entity] = physics
            }
        case .lightBurst:
            let emitter = world.createEntity()
            world.setTransform(.init(position: position, rotation: 0, scale: SIMD3<Float>(repeating: 1)), for: emitter)
            world.setLight(.init(radius: 20, intensity: 5), for: emitter)
        case .shieldPulse:
            for (entity, var health) in world.health where world.players[entity] != nil {
                health.current = min(health.maximum, health.current + 20)
                world.health[entity] = health
            }
        }
    }
}
