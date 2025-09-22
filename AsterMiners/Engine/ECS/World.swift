import Foundation
import simd

final class World {
    var nextID: EntityID = 1
    var transforms: [EntityID: TransformComponent] = [:]
    var physicsBodies: [EntityID: PhysicsComponent] = [:]
    var renderables: [EntityID: RenderComponent] = [:]
    var health: [EntityID: HealthComponent] = [:]
    var ai: [EntityID: AIComponent] = [:]
    var combat: [EntityID: CombatComponent] = [:]
    var collectibles: [EntityID: CollectibleComponent] = [:]
    var lights: [EntityID: LightComponent] = [:]
    var heatZones: [EntityID: HeatComponent] = [:]
    var crystals: [EntityID: CrystalComponent] = [:]
    var players: [EntityID: PlayerComponent] = [:]
    var enemies: [EntityID: EnemyComponent] = [:]
    var particleEmitters: [EntityID: ParticleEmitterComponent] = [:]
    var bosses: [EntityID: BossComponent] = [:]
    var miningTools: [EntityID: MiningToolComponent] = [:]
    var drones: [EntityID: DroneComponent] = [:]
    var heatLights: [EntityID: HeatLightComponent] = [:]

    private(set) var toRemove: [EntityID] = []

    func createEntity() -> EntityID {
        defer { nextID += 1 }
        return nextID
    }

    func destroyEntity(_ entity: EntityID) {
        transforms.removeValue(forKey: entity)
        physicsBodies.removeValue(forKey: entity)
        renderables.removeValue(forKey: entity)
        health.removeValue(forKey: entity)
        ai.removeValue(forKey: entity)
        combat.removeValue(forKey: entity)
        collectibles.removeValue(forKey: entity)
        lights.removeValue(forKey: entity)
        heatZones.removeValue(forKey: entity)
        crystals.removeValue(forKey: entity)
        players.removeValue(forKey: entity)
        enemies.removeValue(forKey: entity)
        particleEmitters.removeValue(forKey: entity)
        bosses.removeValue(forKey: entity)
        miningTools.removeValue(forKey: entity)
        drones.removeValue(forKey: entity)
        heatLights.removeValue(forKey: entity)
    }

    func enqueueRemoval(_ entity: EntityID) {
        toRemove.append(entity)
    }

    func flushRemovals() {
        toRemove.forEach { destroyEntity($0) }
        toRemove.removeAll(keepingCapacity: true)
    }

    func entities<T>(matching keyPath: KeyPath<World, [EntityID: T]>) -> [EntityID] {
        return Array(self[keyPath: keyPath].keys)
    }
}
