import Foundation

// MARK: - Notification.Name Extension
extension Notification.Name {
    static let didAuthenticate = Notification.Name("didAuthenticate")
}

// MARK: - OAuth2Service
final class OAuth2Service {
    
    // MARK: - Singleton
    static let shared = OAuth2Service()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Private Methods
    private func makeTokenRequest(with code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashTokenURL) else {
            print("Ошибка: Неверный URL токена")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("Ошибка: Невозможно создать URL для запроса")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Public Methods
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeTokenRequest(with: code) else {
            print("OAuth2Service: Ошибка: Неверный запрос токена")
            completion(.failure(OAuthError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    OAuth2TokenStorage.shared.token = token
                    
                    NotificationCenter.default.post(name: .didAuthenticate, object: nil)
                    
                    completion(.success(token))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                print("OAuth2Service: Ошибка сети при получении токена: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - OAuthError Enum
    enum OAuthError: Error {
        case invalidRequest
        case invalidResponse
        case noData
    }
}
