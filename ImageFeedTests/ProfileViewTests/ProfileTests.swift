import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.configure(presenterSpy)
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testLogout() {
        // Given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.configure(presenterSpy)
        
        // When
        presenterSpy.didTapLogoutButton()
        
        // Then
        XCTAssertTrue(presenterSpy.logoutCalled)
    }
    
    func testUpdateAvatar() {
        // Given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewControllerSpy.configure(presenter)
        let testURL = "https://test.com/avatar.jpg"
        
        // When
        viewControllerSpy.updateAvatar(with: testURL)
        
        // Then
        XCTAssertTrue(viewControllerSpy.updateAvatarCalled)
        XCTAssertEqual(viewControllerSpy.updatedAvatarURL, testURL)
    }
    
    func testLogoutAlert() {
        // Given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.configure(presenterSpy)
        
        // When
        presenterSpy.didTapLogoutButton()
        
        // Then
        XCTAssertTrue(presenterSpy.logoutCalled)
    }

    
    func testConfigureCall() {
        // Given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        
        // When
        viewControllerSpy.configure(presenter)
        
        // Then
        XCTAssertTrue(viewControllerSpy.configureCalled)
        XCTAssertNotNil(viewControllerSpy.presenter)
    }
    
    func testUpdateProfileDetailsCall() {
        // Given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewControllerSpy.configure(presenter)
        let testName = "Test Name"
        let testLogin = "@testuser"
        let testBio = "Test Bio"
        
        // When
        viewControllerSpy.updateProfileDetails(name: testName, loginName: testLogin, bio: testBio)
        
        // Then
        XCTAssertTrue(viewControllerSpy.updateProfileDetailsCalled)
        XCTAssertEqual(viewControllerSpy.updatedName, testName)
        XCTAssertEqual(viewControllerSpy.updatedLoginName, testLogin)
        XCTAssertEqual(viewControllerSpy.updatedBio, testBio)
    }
}
