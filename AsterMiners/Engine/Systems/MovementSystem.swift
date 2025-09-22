import Foundation
import simd

struct MovementSystem: System {
    func update(world: inout World, input: InputStateActor) {
        for (entity, var transform) in world.transforms {
            guard var physics = world.physicsBodies[entity] else { continue }
            physics.velocity += physics.acceleration * Float(GameTime.fixedTimeStep)
            transform.position += physics.velocity * Float(GameTime.fixedTimeStep)
            physics.velocity *= 0.98
            world.physicsBodies[entity] = physics
            world.transforms[entity] = transform
        }
        world.flushRemovals()
    }
}
