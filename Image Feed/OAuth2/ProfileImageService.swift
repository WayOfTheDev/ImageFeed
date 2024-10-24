import Foundation
import UIKit

// MARK: - ProfileImageService
final class ProfileImageService {
    
    // MARK: - Singleton
    static let shared = ProfileImageService()

    // MARK: - Properties
    private var task: URLSessionTask?
    private(set) var avatarURL: String?

    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: Error - Token Error: No token available")
            completion(.failure(NSError(domain: "Token Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No token available"])))
            return
        }

        guard let profileImageGetURL = URL(string: "users/\(username)", relativeTo: Constants.defaultBaseURL) else {
            print("[ProfileImageService.fetchProfileImageURL]: Error - Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: profileImageGetURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task?.cancel()

        let session = URLSession.shared

        task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil

                switch result {
                case .success(let userResult):
                    if let profileImage = userResult.profileImage {
                        if let avatarURL = profileImage.large {
                            self.avatarURL = avatarURL
                            NotificationCenter.default.post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": avatarURL]
                            )
                            completion(.success(avatarURL))
                        } else {
                            print("[ProfileImageService.fetchProfileImageURL]: Avatar Error - No large avatar URL found")
                            completion(.failure(NSError(domain: "Avatar Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No large avatar URL found"])))
                        }
                    } else {
                        print("[ProfileImageService.fetchProfileImageURL]: Avatar Error - No profile image found")
                        completion(.failure(NSError(domain: "Avatar Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No profile image found"])))
                    }
                case .failure(let error):
                    print("[ProfileImageService.fetchProfileImageURL]: Error - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }

        task?.resume()
    }
}
