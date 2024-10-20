import Foundation

final class OAuth2TokenStorage {
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()

    private let storage = UserDefaults.standard

    // MARK: - Properties
    var token: String? {
        get {
            let token = storage.string(forKey: "OAuthToken")
            return token
        }
        set {
            storage.set(newValue, forKey: "OAuthToken")
            if let token = newValue {
                print("Token saved to storage: \(token)")
            } else {
                print("Token removed from storage")
            }
        }
    }
}
