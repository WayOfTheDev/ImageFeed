import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
        XCTAssertTrue(presenterSpy.viewDidLoadRequestCalled)
    }
    
    func testPresenterCallsUpdateTableView() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        viewController.updateTableViewAnimated()
        
        // Then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
    
    func testGetPhoto() {
        // Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // When
        let photoResult = PhotoResult(
            id: "test",
            createdAt: "2020-01-01T00:00:00Z",
            updatedAt: "2020-01-01T00:00:00Z",
            width: 0,
            height: 0,
            color: "#000000",
            blurHash: "test",
            likes: 0,
            likedByUser: false,
            description: nil,
            urls: UrlsResult(raw: "", full: "test_full_url", regular: "", small: "", thumb: "test_url")
        )
        let testPhoto = Photo(from: photoResult)
        
        presenter.photos = [testPhoto]
        let photo = presenter.makePhotoCellConfig(for: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertEqual(photo.id, testPhoto.id)
        XCTAssertEqual(photo.size, testPhoto.size)
        XCTAssertEqual(photo.isLiked, testPhoto.isLiked)
    }

    func testChangeLike() {
        // Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // When
        let photoResult = PhotoResult(
            id: "test",
            createdAt: "2020-01-01T00:00:00Z",
            updatedAt: "2020-01-01T00:00:00Z",
            width: 0,
            height: 0,
            color: "#000000",
            blurHash: "test",
            likes: 0,
            likedByUser: false,
            description: nil,
            urls: UrlsResult(raw: "", full: "test_full_url", regular: "", small: "", thumb: "test_url")
        )
        let testPhoto = Photo(from: photoResult)
        
        presenter.changeLike(for: testPhoto)
        
        // Then
        XCTAssertTrue(presenter.changeLikeCalled)
    }
    
    func testPresenterCheckPagination() {
        // Given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        let lastIndex = 4
        
        // When
        presenterSpy.checkPagination(index: lastIndex)
        
        // Then
        XCTAssertTrue(presenterSpy.checkPaginationCalled)
        XCTAssertEqual(presenterSpy.lastCheckedIndex, lastIndex)
    }
}
