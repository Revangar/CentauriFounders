import Foundation

struct SaveData: Codable {
    struct Unlocks: Codable {
        var unlockedClasses: Set<String>
        var craftedBlueprints: Set<String>
        var currency: Int
    }

    struct Options: Codable {
        var autoAim: Bool
        var joystickScale: Float
        var language: String
        var haptics: Bool
        var graphicsQuality: Int
    }

    var unlocks: Unlocks
    var options: Options
    var checksum: String
}

enum SaveError: Error {
    case corrupted
    case ioError
}

final class SaveService {
    static let shared = SaveService()
    private let queue = DispatchQueue(label: "save.queue")
    private var cached: SaveData?

    private init() {}

    func load() throws -> SaveData {
        if let cached { return cached }
        let url = try saveURL()
        guard let data = try? Data(contentsOf: url) else {
            let defaults = SaveData(unlocks: .init(unlockedClasses: ["prospector"], craftedBlueprints: [], currency: 0), options: .init(autoAim: true, joystickScale: 1.0, language: Locale.current.language.languageCode?.identifier ?? "en", haptics: true, graphicsQuality: 2), checksum: "")
            try persist(defaults)
            cached = defaults
            return defaults
        }
        let decoded = try JSONDecoder().decode(SaveData.self, from: data)
        let computed = Self.checksum(for: decoded)
        guard decoded.checksum == computed else {
            throw SaveError.corrupted
        }
        cached = decoded
        return decoded
    }

    func persist(_ data: SaveData) throws {
        let url = try saveURL()
        var payload = data
        payload.checksum = Self.checksum(for: data)
        let encoded = try JSONEncoder().encode(payload)
        do {
            try encoded.write(to: url, options: .atomic)
            cached = payload
        } catch {
            throw SaveError.ioError
        }
    }

    private func saveURL() throws -> URL {
        guard let container = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw SaveError.ioError
        }
        return container.appendingPathComponent("save.json")
    }

    private static func checksum(for data: SaveData) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let raw = (try? encoder.encode(data.unlocks)) ?? Data()
        return raw.base64EncodedString()
    }
}
