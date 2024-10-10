import Foundation

// MARK: - Notification.Name Extension
extension Notification.Name {
    static let didAuthenticate = Notification.Name("didAuthenticate")
}

// MARK: - OAuth2Service
final class OAuth2Service {
    
    // MARK: - Private Methods
    private func makeTokenRequest(with code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
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
        print("OAuth2Service: fetchOAuthToken вызван с кодом: \(code)")
        print("OAuth2Service: Начало запроса токена с кодом: \(code)")
        guard let request = makeTokenRequest(with: code) else {
            print("OAuth2Service: Ошибка: Неверный запрос токена")
            completion(.failure(OAuthError.invalidRequest))
            return
        }
        
        print("OAuth2Service: URL запроса токена: \(request.url?.absoluteString ?? "nil")")
        
        let task = URLSession.shared.data(for: request) { result in
            print("OAuth2Service: Получен ответ на запрос токена")
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    OAuth2TokenStorage.shared.token = token
                    print("OAuth2Service: Токен успешно получен и сохранен: \(token)")
                    
                    NotificationCenter.default.post(name: .didAuthenticate, object: nil)
                    
                    completion(.success(token))
                } catch {
                    print("OAuth2Service: Ошибка декодирования токена: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("OAuth2Service: Ошибка сети при получении токена: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
        print("OAuth2Service: Запрос токена отправлен")
    }
    
    // MARK: - OAuthError Enum
    enum OAuthError: Error {
        case invalidRequest
        case invalidResponse
        case noData
    }
}
