import Foundation

final class UpgradeSystem: System {
    private var levelInterval: Int = 100

    func update(world: inout World, input: InputStateActor) {
        for (entity, var player) in world.players {
            if player.experience >= levelInterval * player.level {
                player.level += 1
                player.pendingUpgrades = UpgradeCatalog.shared.randomDraft(for: player, count: 3)
                world.players[entity] = player
            }
        }
    }
}
