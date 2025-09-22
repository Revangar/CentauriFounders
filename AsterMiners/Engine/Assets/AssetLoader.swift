import Foundation

final class AssetLoader {
    private let decoder = JSONDecoder()

    func loadWeaponConfigs() -> [WeaponConfig] {
        loadJSON(named: "weapons")
    }

    func loadEnemyConfigs() -> [EnemyConfig] {
        loadJSON(named: "enemies")
    }

    func loadBiomeConfigs() -> [BiomeConfig] {
        loadJSON(named: "biomes")
    }

    func loadUpgradeConfigs() -> [UpgradeConfig] {
        loadJSON(named: "upgrades")
    }

    private func loadJSON<T: Decodable>(named name: String) -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("Missing config \(name)")
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to load \(name): \(error)")
        }
    }
}

struct WeaponConfig: Codable {
    var identifier: String
    var displayNameKey: String
    var fireRate: Float
    var damage: Float
    var type: CombatComponent.WeaponType
}

struct EnemyConfig: Codable {
    var identifier: String
    var health: Float
    var speed: Float
    var behavior: String
}

struct BiomeConfig: Codable {
    var identifier: String
    var nameKey: String
    var descriptionKey: String
    var heatLevel: Float
}

struct UpgradeConfig: Codable {
    var identifier: String
    var nameKey: String
    var descriptionKey: String
    var modifiers: [String: Float]
    var tags: [String]
}
