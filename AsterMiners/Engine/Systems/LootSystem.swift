import Foundation

struct LootSystem: System {
    func update(world: inout World, input: InputStateActor) {
        for (entity, collectible) in world.collectibles where collectible.value > 0 {
            if let playerID = world.players.keys.first, let playerTransform = world.transforms[playerID], let transform = world.transforms[entity] {
                let distance = simd_distance(playerTransform.position, transform.position)
                if distance < 1.5 {
                    grant(collectible, to: playerID, world: &world)
                    world.enqueueRemoval(entity)
                }
            }
        }
    }

    private func grant(_ collectible: CollectibleComponent, to player: EntityID, world: inout World) {
        switch collectible.kind {
        case .ore:
            if var playerComponent = world.players[player] {
                playerComponent.experience += Int(collectible.value)
                world.players[player] = playerComponent
            }
        case .blueprint:
            if var save = try? SaveService.shared.load() {
                save.unlocks.craftedBlueprints.insert("bp_\(collectible.value)")
                try? SaveService.shared.persist(save)
            }
        case .heal:
            if var health = world.health[player] {
                health.current = min(health.maximum, health.current + collectible.value)
                world.health[player] = health
            }
        }
    }
}
