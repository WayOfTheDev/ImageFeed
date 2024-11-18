import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    private(set) var photos: [Photo] = []
    
    private var isUpdatingTableView = false
    
    // MARK: - ImagesListPresenterProtocol
    func viewDidLoad() {
        setupObserver()
    }
    
    func viewDidLoadRequest() {
        if OAuth2TokenStorage.shared.token != nil {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    // MARK: - Cell Configuration
    func makePhotoCellConfig(for indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    // MARK: - Actions
    func changeLike(for photo: Photo) {
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success():
                break
            case .failure:
                self?.view?.showError(with: "Не удалось изменить статус лайка. Попробуйте еще раз.")
            }
        }
    }

    func didTapImage(at indexPath: IndexPath) -> String {
        return photos[indexPath.row].fullImageURL
    }
    
    // MARK: - Pagination
    func checkPagination(index: Int) {
        if ProcessInfo.processInfo.isUITest {
            return
        }
        
        if index == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    // MARK: - Private Methods
    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveImagesListServiceChange(notification:)),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func didReceiveImagesListServiceChange(notification: Notification) {
        guard !isUpdatingTableView else { return }
        isUpdatingTableView = true
        
        if let userInfo = notification.userInfo,
           let photoId = userInfo["photoId"] as? String,
           let index = imagesListService.photos.firstIndex(where: { $0.id == photoId }) {
            photos[index].isLiked = imagesListService.photos[index].isLiked
            let indexPath = IndexPath(row: index, section: 0)
            view?.updateLikeStatus(at: indexPath, isLiked: photos[index].isLiked)
        } else {
            photos = imagesListService.photos
            view?.updateTableViewAnimated()
        }
        
        isUpdatingTableView = false
    }

}
