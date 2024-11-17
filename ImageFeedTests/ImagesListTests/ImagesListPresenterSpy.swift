@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    var viewDidLoadCalled: Bool = false
    var viewDidLoadRequestCalled: Bool = false
    var checkPaginationCalled: Bool = false
    var changeLikeCalled: Bool = false
    var lastCheckedIndex: Int?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveImagesListServiceChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    func viewDidLoadRequest() {
        viewDidLoadRequestCalled = true
    }
    
    func makePhotoCellConfig(for indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func changeLike(for photo: Photo) {
        changeLikeCalled = true
    }
    
    func didTapImage(at indexPath: IndexPath) -> String {
        return ""
    }
    
    func checkPagination(index: Int) {
        checkPaginationCalled = true
        lastCheckedIndex = index
    }
    
    @objc private func didReceiveImagesListServiceChange() {
        DispatchQueue.main.async { [weak self] in
            self?.view?.updateTableViewAnimated()
        }
    }
}
