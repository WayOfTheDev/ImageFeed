import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableViewAnimated()
    func reloadRows(at indexPaths: [IndexPath])
    func showError(with message: String)
    func configureCell(_ cell: ImagesListCell, with photo: Photo, indexPath: IndexPath)
    func updateLikeStatus(at indexPath: IndexPath, isLiked: Bool)
}
