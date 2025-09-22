import XCTest
@testable import AsterMiners

final class GameplayTests: XCTestCase {
    func testSeedReproducibility() {
        var generatorA = SeededGenerator(seed: 42)
        var generatorB = SeededGenerator(seed: 42)
        for _ in 0..<100 {
            XCTAssertEqual(generatorA.next(), generatorB.next())
        }
    }
}
