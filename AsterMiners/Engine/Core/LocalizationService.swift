import Foundation

final class LocalizationService {
    static let shared = LocalizationService()
    private(set) var bundle: Bundle = .main
    private var observers: [(String) -> Void] = []

    private init() {}

    func bootstrap() {
        do {
            let save = try SaveService.shared.load()
            switchLanguage(save.options.language)
        } catch {
            switchLanguage(Locale.current.language.languageCode?.identifier ?? "en")
        }
    }

    func localized(_ key: String, arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, bundle: bundle, comment: "")
        guard !arguments.isEmpty else { return format }
        return String(format: format, arguments: arguments)
    }

    func switchLanguage(_ code: String) {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"), let bundle = Bundle(path: path) else {
            self.bundle = .main
            return
        }
        self.bundle = bundle
        observers.forEach { $0(code) }
    }

    func addObserver(_ observer: @escaping (String) -> Void) {
        observers.append(observer)
    }
}
