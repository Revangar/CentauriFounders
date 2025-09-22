import Foundation

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0xABCDEF : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 7
        state ^= state >> 9
        state ^= state << 8
        return state
    }
}

struct RNGService {
    private var generator: SeededGenerator
    private let seed: UInt64

    init(seed: UInt64) {
        self.seed = seed
        self.generator = SeededGenerator(seed: seed)
    }

    mutating func nextFloat() -> Float {
        return Float(Double(next()) / Double(UInt64.max))
    }

    mutating func next() -> UInt64 {
        return generator.next()
    }

    func currentSeed() -> UInt64 {
        seed
    }
}
