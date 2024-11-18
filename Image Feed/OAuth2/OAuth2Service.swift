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
                print("[OAuth2Service.fetchOAuthToken]: OAuth2ServiceError - invalidRequest (Duplicate code)")
                completion(.failure(OAuth2ServiceError.invalidRequest))
                return
            }
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service.fetchOAuthToken]: OAuth2ServiceError - invalidRequest (Invalid request)")
            completion(.failure(OAuth2ServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
                
                switch result {
                case .success(let responseBody):
                    OAuth2TokenStorage.shared.token = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                case .failure(let error):
                    print("[OAuth2Service.fetchOAuthToken]: Error - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        task?.resume()
    }
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let configuration = AuthConfiguration.standard
        guard var urlComponents = URLComponents(string: configuration.unsplashTokenURL) else {
            print("[OAuth2Service.makeOAuthTokenRequest]: Error - Invalid URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "client_secret", value: configuration.secretKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("[OAuth2Service.makeOAuthTokenRequest]: Error - Unable to create URL from components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Struct OAuthTokenResponseBody
    struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}
