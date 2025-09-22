import Foundation
import simd

struct LightingSystem: System {
    func update(world: inout World, input: InputStateActor) {
        for (entity, var light) in world.lights {
            light.intensity = max(0, light.intensity - 0.01)
            if light.intensity <= 0.01 {
                world.enqueueRemoval(entity)
            } else {
                world.lights[entity] = light
            }
        }
    }
}
