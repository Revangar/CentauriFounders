import Foundation
import simd

enum ArenaGenerator {
    static func generate(in world: inout World, context: RunContext) {
        let radius: Float = 20
        let segments = 32
        for i in 0..<segments {
            let angle = Float(i) / Float(segments) * Float.pi * 2
            let position = SIMD3<Float>(cos(angle) * radius, 0, sin(angle) * radius)
            let prop = world.createEntity()
            world.setTransform(.init(position: position, rotation: angle, scale: SIMD3<Float>(repeating: 1.0)), for: prop)
            world.setRender(.init(mesh: .prop, color: SIMD4<Float>(0.1, 0.4, 0.2, 1), emissive: 0.0), for: prop)
        }
        let crystalPositions: [SIMD3<Float>] = [
            SIMD3<Float>(-8, 0, -4),
            SIMD3<Float>(6, 0, -3),
            SIMD3<Float>(2, 0, 7)
        ]
        let buffs: [CrystalComponent.BuffType] = [.slowField, .lightBurst, .shieldPulse]
        for (index, position) in crystalPositions.enumerated() {
            EntityFactory.spawnCrystal(in: &world, at: position, buff: buffs[index % buffs.count])
        }
    }
}
