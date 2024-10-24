import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()

    // MARK: - Properties
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "OAuthToken")
        }
        set {
            if let token = newValue {
                let saveSuccessful: Bool = KeychainWrapper.standard.set(token, forKey: "OAuthToken")
                #if DEBUG
                if saveSuccessful {
                    print("Token successfully saved to Keychain.")
                } else {
                    print("Failed to save token to Keychain.")
                }
                #endif
            } else {
                let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "OAuthToken")
                #if DEBUG
                if removeSuccessful {
                    print("Token successfully removed from Keychain.")
                } else {
                    print("Failed to remove token from Keychain.")
                }
                #endif
            }
        }
    }
}
