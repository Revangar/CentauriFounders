import Foundation
import Combine
import UIKit

final class MainMenuViewModel: ObservableObject {
    @Published var showSettings = false
    @Published var showMeta = false
    @Published var selectedClass = "prospector"
    @Published var difficulty = 1
    @Published var autoAim = true
    @Published var joystickScale: Double = 1.0
    @Published var languageCode: String = "en"
    @Published var graphicsQuality: Int = 2

    private var cancellables: Set<AnyCancellable> = []

    init() {
        if let save = try? SaveService.shared.load() {
            autoAim = save.options.autoAim
            joystickScale = Double(save.options.joystickScale)
            languageCode = save.options.language
            graphicsQuality = save.options.graphicsQuality
        }
    }

    func startRun() {
        let configuration = RunConfiguration(difficulty: difficulty, seed: UInt64(Date().timeIntervalSince1970), selectedClass: selectedClass)
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = scene.delegate as? SceneDelegate {
                delegate.switchToGame(with: configuration)
            }
        }
    }

    func toggleLanguage() {
        languageCode = languageCode == "en" ? "ru" : "en"
        LocalizationService.shared.switchLanguage(languageCode)
        persistOptions()
    }

    func persistOptions() {
        guard var save = try? SaveService.shared.load() else { return }
        save.options.autoAim = autoAim
        save.options.joystickScale = Float(joystickScale)
        save.options.language = languageCode
        save.options.graphicsQuality = graphicsQuality
        try? SaveService.shared.persist(save)
    }

    func resetProgress() {
        let defaults = SaveData(unlocks: .init(unlockedClasses: ["prospector"], craftedBlueprints: [], currency: 0), options: .init(autoAim: true, joystickScale: 1.0, language: languageCode, haptics: true, graphicsQuality: graphicsQuality), checksum: "")
        try? SaveService.shared.persist(defaults)
        autoAim = defaults.options.autoAim
        joystickScale = Double(defaults.options.joystickScale)
    }
}
