import Foundation

// MARK: - ImagesListService
final class ImagesListService {
    
    // MARK: - Singleton
    static let shared = ImagesListService()
    
    // MARK: - Properties
    private(set) var photos: [Photo] = []
    private var currentPage: Int = 1
    private var isFetching: Bool = false
    private let perPage: Int = 10
    private let urlSession = URLSession.shared
    
    // MARK: - Notification
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Public Methods
    func fetchPhotosNextPage() {
        guard !isFetching else {
            return
        }
        
        isFetching = true
        let pageToFetch = currentPage
        
        guard let baseURL = Constants.defaultBaseURL else {
            isFetching = false
            return
        }
        
        let url = baseURL.appendingPathComponent("photos")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(pageToFetch)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let finalURL = urlComponents?.url else {
            isFetching = false
            return
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.currentPage += 1
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("ImagesListService.fetchPhotosNextPage: Ошибка при загрузке фотографий - \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                self.isFetching = false
            }
        }
        
        task.resume()
    }
    
    // MARK: - ChangeLike method
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let httpMethod = isLike ? "POST" : "DELETE"
        
        guard let baseURL = Constants.defaultBaseURL else {
            completion(.failure(NetworkError.invalidImageData))
            return
        }
        
        let url = baseURL.appendingPathComponent("photos/\(photoId)/like")
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResponse, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let likeResponse):
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        var photo = self.photos[index]
                        photo.isLiked = likeResponse.photo.likedByUser
                        self.photos[index] = photo
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                        completion(.success(()))
                    } else {
                        completion(.failure(NetworkError.invalidImageData))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("ImagesListService.changeLike: Ошибка при изменении лайка - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

extension ImagesListService {
    func reset() {
        photos = []
        currentPage = 1
    }
}
