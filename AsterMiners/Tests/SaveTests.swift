import XCTest
@testable import AsterMiners

final class SaveTests: XCTestCase {
    func testSaveAndLoadRoundtrip() throws {
        var save = try SaveService.shared.load()
        let originalCurrency = save.unlocks.currency
        save.unlocks.currency += 100
        try SaveService.shared.persist(save)
        let loaded = try SaveService.shared.load()
        XCTAssertEqual(loaded.unlocks.currency, originalCurrency + 100)
        save.unlocks.currency = originalCurrency
        try SaveService.shared.persist(save)
    }
}
