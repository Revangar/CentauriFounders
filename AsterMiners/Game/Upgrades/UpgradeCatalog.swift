import Foundation

final class UpgradeCatalog {
    static let shared = UpgradeCatalog()
    private var upgrades: [Upgrade]

    private init() {
        self.upgrades = []
    }

    func configure(with configs: [UpgradeConfig]) {
        upgrades = configs.map { config in
            let modifiers = config.modifiers.map { key, value -> Upgrade.Modifier in
                switch key {
                case "fireRate": return Upgrade.Modifier(kind: .fireRate(value))
                case "damage": return Upgrade.Modifier(kind: .damage(value))
                case "movement": return Upgrade.Modifier(kind: .movement(value))
                case "shield": return Upgrade.Modifier(kind: .shield(value))
                case "light": return Upgrade.Modifier(kind: .lightRadius(value))
                default: return Upgrade.Modifier(kind: .movement(0))
                }
            }
            return Upgrade(identifier: config.identifier, nameKey: config.nameKey, descriptionKey: config.descriptionKey, modifiers: modifiers, synergyTags: config.tags)
        }
    }

    func randomDraft(for player: PlayerComponent, count: Int) -> [Upgrade] {
        let shuffled = upgrades.shuffled().prefix(count)
        return Array(shuffled)
    }
}
