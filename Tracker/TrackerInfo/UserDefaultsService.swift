import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard

    private init() { }

    // MARK: - Keys
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }

    // MARK: - Properties
    var hasSeenOnboarding: Bool {
        get {
            defaults.bool(forKey: Keys.hasSeenOnboarding)
        }
        set {
            defaults.set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }

    // MARK: - Helper Methods

    func resetAll() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }

    func hasValue(for key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
}
