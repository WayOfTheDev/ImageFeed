import Foundation
import UIKit

private enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidImageData
}

extension URLSession {
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[data(for:)]: NetworkError - HTTP Status Code: \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[data(for:)]: NetworkError - URLRequestError: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[data(for:)]: NetworkError - URLSessionError")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = self.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let dataString = String(data: data, encoding: .utf8) ?? "Unable to convert data to String"
                    print("[objectTask(for:)]: DecodingError - \(error.localizedDescription), Data: \(dataString)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[objectTask(for:)]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
    
    func imageTask(
        for url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) -> URLSessionTask {
        let request = URLRequest(url: url)
        
        let task = self.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    print("[imageTask(for:)]: NetworkError - Invalid Image Data")
                    completion(.failure(NetworkError.invalidImageData))
                }
            case .failure(let error):
                print("[imageTask(for:)]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
