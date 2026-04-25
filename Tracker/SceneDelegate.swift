import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        print("🔥 SCENE DELEGATE WORKS!")

        guard let windowScene = (scene as? UIWindowScene) else {
            print("❌ NO WINDOW SCENE!")
            return
        }

        window = UIWindow(windowScene: windowScene)

        let hasSeenOnboarding = UserDefaultsService.shared.hasSeenOnboarding

        if hasSeenOnboarding {
            window?.rootViewController = MainTabBarController()
        } else {
            window?.rootViewController = OnboardingViewController()
        }

        window?.makeKeyAndVisible()
    }
}
