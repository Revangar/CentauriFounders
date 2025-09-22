import Foundation
import simd

enum EntityFactory {
    static func populatePlayer(in world: inout World, context: RunContext) {
        let player = world.createEntity()
        let transform = TransformComponent(position: SIMD3<Float>(0, 0, 0), rotation: 0, scale: SIMD3<Float>(repeating: 1.2))
        let physics = PhysicsComponent(velocity: .zero, acceleration: .zero)
        let render = RenderComponent(mesh: .player, color: SIMD4<Float>(0.4, 0.9, 1.0, 1), emissive: 0.5)
        let health = HealthComponent(current: 120, maximum: 120)
        let combat = CombatComponent(weapon: .beam, cooldown: 0, fireRate: 2.5)
        let playerComponent = PlayerComponent(experience: 0, level: 1, pendingUpgrades: [])
        let miningTool = MiningToolComponent(efficiency: 1.0, cooldown: 1.0, timer: 0)
        world.setTransform(transform, for: player)
        world.setPhysics(physics, for: player)
        world.setRender(render, for: player)
        world.setHealth(health, for: player)
        world.setCombat(combat, for: player)
        world.setPlayer(playerComponent, for: player)
        world.setMiningTool(miningTool, for: player)
        let light = LightComponent(radius: 12, intensity: 2.5)
        world.setLight(light, for: player)
    }

    static func spawnCrystal(in world: inout World, at position: SIMD3<Float>, buff: CrystalComponent.BuffType) {
        let crystal = world.createEntity()
        world.setTransform(.init(position: position, rotation: 0, scale: SIMD3<Float>(repeating: 1.2)), for: crystal)
        world.setRender(.init(mesh: .crystal, color: SIMD4<Float>(0.6, 0.8, 1.0, 1), emissive: 1.0), for: crystal)
        world.setHealth(.init(current: 60, maximum: 60), for: crystal)
        world.setCrystal(.init(buff: buff, remaining: 60, max: 60), for: crystal)
        world.setParticle(.init(rate: 12, particleColor: SIMD4<Float>(0.2, 0.6, 1.0, 1), lifetime: 1.5), for: crystal)
    }
}
