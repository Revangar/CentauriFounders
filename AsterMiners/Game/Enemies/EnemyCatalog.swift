import Foundation

struct EnemyArchetype {
    var identifier: String
    var displayNameKey: String
    var descriptionKey: String
}

enum EnemyCatalog {
    static func archetypes() -> [EnemyArchetype] {
        let configs: [EnemyConfig] = AssetLoader().loadEnemyConfigs()
        return configs.map { EnemyArchetype(identifier: $0.identifier, displayNameKey: "enemy_\($0.identifier)_name", descriptionKey: "enemy_\($0.identifier)_desc") }
    }
}
