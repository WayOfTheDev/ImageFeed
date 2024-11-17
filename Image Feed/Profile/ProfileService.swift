import Foundation

// MARK: - ProfileService
final class ProfileService {
    
    // MARK: - Singleton
    static let shared = ProfileService()
    
    // MARK: - Properties
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        let configuration = AuthConfiguration.standard
        
        let url = configuration.defaultBaseURL.appendingPathComponent("me")
        
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
    
    // MARK: - Reset Method
    func reset() {
        profile = nil
    }
}
