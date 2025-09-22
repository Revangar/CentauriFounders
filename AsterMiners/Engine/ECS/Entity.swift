import Foundation
import simd

typealias EntityID = Int

struct TransformComponent {
    var position: SIMD3<Float>
    var rotation: Float
    var scale: SIMD3<Float>
}

struct PhysicsComponent {
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
}

struct RenderComponent {
    var mesh: MeshIdentifier
    var color: SIMD4<Float>
    var emissive: Float
}

struct HealthComponent {
    var current: Float
    var maximum: Float
}

struct AIComponent {
    enum Behavior {
        case swarm
        case burrow
        case spit
        case shield
        case boss
    }
    var behavior: Behavior
    var target: EntityID?
}

struct CombatComponent {
    enum WeaponType: String, Codable {
        case beam
        case shotgun
        case orbital
        case drone
    }
    var weapon: WeaponType
    var cooldown: Float
    var fireRate: Float
}

struct CollectibleComponent {
    enum Kind: String {
        case ore
        case blueprint
        case heal
    }
    var kind: Kind
    var value: Float
}

struct LightComponent {
    var radius: Float
    var intensity: Float
}

struct HeatComponent {
    var temperature: Float
    var dissipate: Float
}

struct CrystalComponent {
    var buff: BuffType
    var remaining: Float
    var max: Float

    enum BuffType: String {
        case slowField
        case lightBurst
        case shieldPulse
    }
}

struct PlayerComponent {
    var experience: Int
    var level: Int
    var pendingUpgrades: [Upgrade]
}

struct EnemyComponent {
    var archetype: String
    var spawnTime: TimeInterval
}

struct Upgrade {
    var identifier: String
    var nameKey: String
    var descriptionKey: String
    var modifiers: [Modifier]
    var synergyTags: [String]

    struct Modifier {
        enum Kind {
            case fireRate(Float)
            case damage(Float)
            case movement(Float)
            case shield(Float)
            case lightRadius(Float)
        }
        var kind: Kind
    }
}

struct ParticleEmitterComponent {
    var rate: Float
    var particleColor: SIMD4<Float>
    var lifetime: Float
}

struct BossComponent {
    var phase: Int
    var timers: [String: Float]
}

struct MiningToolComponent {
    var efficiency: Float
    var cooldown: Float
    var timer: Float
}

struct DroneComponent {
    var orbitRadius: Float
    var orbitSpeed: Float
    var damage: Float
}

struct HeatLightComponent {
    var heat: Float
    var light: Float
}

enum MeshIdentifier: String {
    case player
    case swarmling
    case burrower
    case spitter
    case shielder
    case boss
    case crystal
    case projectile
    case drone
    case prop
}
