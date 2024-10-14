import Foundation

// MARK: - OAuth2ServiceError Enum
enum OAuth2ServiceError: Error {
    case invalidRequest
}

// MARK: - OAuth2Service
final class OAuth2Service {
    
    // MARK: - Singleton
    static let shared = OAuth2Service()
    
    // MARK: - Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(OAuth2ServiceError.invalidRequest))
                return
            }
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(OAuth2ServiceError.invalidRequest))
            return
        }
        
        task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(OAuth2ServiceError.invalidRequest))
                    return
                }
                
                do {
                    let token = try self?.parseToken(from: data)
                    if let token = token {
                        OAuth2TokenStorage.shared.token = token
                        completion(.success(token))
                    } else {
                        completion(.failure(OAuth2ServiceError.invalidRequest))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task?.resume()
    }
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
    
    private func parseToken(from data: Data) throws -> String {
        struct OAuthTokenResponseBody: Decodable {
            let accessToken: String
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
        
        return response.accessToken
    }
}
