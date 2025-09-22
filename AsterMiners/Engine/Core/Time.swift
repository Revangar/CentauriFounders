import Foundation

struct GameTime {
    static let fixedTimeStep: TimeInterval = 1.0 / 60.0
    var accumulator: TimeInterval = 0
    var currentTime: TimeInterval = 0

    mutating func advance(by delta: TimeInterval, simulate: () -> Void) {
        accumulator += delta
        while accumulator >= Self.fixedTimeStep {
            simulate()
            accumulator -= Self.fixedTimeStep
            currentTime += Self.fixedTimeStep
        }
    }
}
