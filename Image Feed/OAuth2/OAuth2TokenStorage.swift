import Foundation

final class OAuth2TokenStorage {
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()

    private let storage = UserDefaults.standard

    // MARK: - Properties
    var token: String? {
        get {
            return storage.string(forKey: "OAuthToken")
        }
        set {
            storage.set(newValue, forKey: "OAuthToken")
        }
    }
}
