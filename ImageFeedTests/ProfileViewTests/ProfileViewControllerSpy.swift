@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateAvatarCalled: Bool = false
    var updateProfileDetailsCalled: Bool = false
    var showLoadingErrorCalled: Bool = false
    var configureCalled: Bool = false
    var didTapLogoutButtonCalled: Bool = false
    
    var updatedAvatarURL: String?
    var updatedName: String?
    var updatedLoginName: String?
    var updatedBio: String?
    
    var presenter: ProfilePresenterProtocol?
    
    func updateAvatar(with url: String?) {
        updateAvatarCalled = true
        updatedAvatarURL = url
    }
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
        updatedName = name
        updatedLoginName = loginName
        updatedBio = bio
    }
    
    func showLoadingError() {
        showLoadingErrorCalled = true
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        configureCalled = true
        self.presenter = presenter
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
}
