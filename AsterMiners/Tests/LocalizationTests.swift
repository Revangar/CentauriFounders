import XCTest
@testable import AsterMiners

final class LocalizationTests: XCTestCase {
    func testKeyParityBetweenLanguages() throws {
        let english = try keys(for: "en")
        let russian = try keys(for: "ru")
        XCTAssertEqual(english, russian)
    }

    private func keys(for code: String) throws -> Set<String> {
        var allKeys: Set<String> = []
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: code), let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            allKeys.formUnion(dict.keys)
        }
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "stringsdict", inDirectory: nil, forLocalization: code), let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            allKeys.formUnion(dict.keys)
        }
        if allKeys.isEmpty {
            throw NSError(domain: "Localization", code: 0)
        }
        return allKeys
    }
}
