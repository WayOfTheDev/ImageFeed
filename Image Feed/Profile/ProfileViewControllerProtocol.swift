import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func updateAvatar(with url: String?)
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func showLoadingError()
    func configure(_ presenter: ProfilePresenterProtocol)
    func didTapLogoutButton()
}
