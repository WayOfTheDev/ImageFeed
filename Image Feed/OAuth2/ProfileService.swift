import Foundation

// MARK: - ProfileResult
struct ProfileResult: Codable {
    let username: String
    let name: String?
    let bio: String?
    let profileImage: ProfileImage?

    enum CodingKeys: String, CodingKey {
        case username, name, bio
        case profileImage = "profile_image"
    }
    
    struct ProfileImage: Codable {
        let small: String?
        let medium: String?
        let large: String?
    }
}

// MARK: - Profile
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    let profileImageURL: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        self.name = result.name ?? "No name"
        self.loginName = "@\(result.username)"
        self.bio = result.bio ?? "В процессе разработки"
        self.profileImageURL = result.profileImage?.large
    }
}

// MARK: - ProfileService
final class ProfileService {
    
    // MARK: - Singleton
    static let shared = ProfileService()
    
    // MARK: - Properties
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let baseURL = Constants.defaultBaseURL else {
            print("[ProfileService.fetchProfile]: Error - Invalid default base URL")
            completion(.failure(NSError(domain: "Invalid base URL", code: 0, userInfo: nil)))
            return
        }
        
        let url = baseURL.appendingPathComponent("me")
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                self?.task = nil

                switch result {
                case .success(let profileResult):
                    let profile = Profile(from: profileResult)
                    self?.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService.fetchProfile]: Error - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        task?.resume()
    }
}
