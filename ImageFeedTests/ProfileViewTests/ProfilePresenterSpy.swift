@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var loadAvatarCalled: Bool = false
    var logoutCalled: Bool = false
    
    var updateProfileDetailsCalled: Bool = false
    
    
    var loadedUsername: String?
    
    weak var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateProfileDetails() {
        updateProfileDetailsCalled = true
    }
    
    func loadAvatar(username: String) {
        loadAvatarCalled = true
        loadedUsername = username
    }
    
    func didTapLogoutButton() {
        logoutCalled = true
        view?.didTapLogoutButton()
    }
    
    func logout() {}
}
