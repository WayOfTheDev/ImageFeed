@testable import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    func updateLikeStatus(at indexPath: IndexPath, isLiked: Bool) {}
    
    var presenter: ImagesListPresenterProtocol?
    
    var updateTableViewAnimatedCalled: Bool = false
    var reloadRowsCalled: Bool = false
    var showErrorCalled: Bool = false
    var lastReloadedIndexPaths: [IndexPath]?
    var lastErrorMessage: String?
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        reloadRowsCalled = true
        lastReloadedIndexPaths = indexPaths
    }
    
    func showError(with message: String) {
        showErrorCalled = true
        lastErrorMessage = message
    }
    
    func configureCell(_ cell: ImagesListCell, with photo: Photo, indexPath: IndexPath) {}
}
