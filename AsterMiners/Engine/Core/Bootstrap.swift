import Foundation

struct RunConfiguration {
    var difficulty: Int
    var seed: UInt64
    var selectedClass: String
}

struct RunContext {
    var configuration: RunConfiguration
    var rng: RNGService
}
