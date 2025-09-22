import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var menuHosting: UIHostingController<MainMenuView>?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let viewModel = MainMenuViewModel()
        let rootView = MainMenuView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: rootView)
        menuHosting = hosting
        window.rootViewController = hosting
        window.makeKeyAndVisible()
        self.window = window
    }

    func switchToGame(with runConfiguration: RunConfiguration) {
        guard let window = window else { return }
        let controller = GameViewController(runConfiguration: runConfiguration)
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }

    func returnToMenu() {
        guard let window = window else { return }
        let viewModel = MainMenuViewModel()
        let rootView = MainMenuView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: rootView)
        menuHosting = hosting
        window.rootViewController = hosting
        window.makeKeyAndVisible()
    }
}
