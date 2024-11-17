import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    
    func viewDidLoad()
    func viewDidLoadRequest()
    func makePhotoCellConfig(for indexPath: IndexPath) -> Photo
    func changeLike(for photo: Photo)
    func didTapImage(at indexPath: IndexPath) -> String
    func checkPagination(index: Int)
}
