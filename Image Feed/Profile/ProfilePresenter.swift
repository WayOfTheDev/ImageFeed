import Foundation
import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    // MARK: - Properties
    weak var view: ProfileViewControllerProtocol?
    private var profileImageObserver: NSObjectProtocol?
    
    // MARK: - Initializer
    init() {
        setupProfileImageObserver()
    }
    
    deinit {
        if let profileImageObserver = profileImageObserver {
            NotificationCenter.default.removeObserver(profileImageObserver)
        }
    }
    
    // MARK: - ProfilePresenterProtocol
    func viewDidLoad() {
        updateProfileDetails()
    }
    
    func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else { return }
        
        view?.updateProfileDetails(
            name: profile.name,
            loginName: profile.loginName,
            bio: profile.bio ?? "В процессе разработки"
        )
        
        if let avatarURL = profile.profileImageURL {
            view?.updateAvatar(with: avatarURL)
        } else {
            loadAvatar(username: profile.username)
        }
    }
    
    func loadAvatar(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let avatarURL):
                    self?.view?.updateAvatar(with: avatarURL)
                case .failure:
                    self?.view?.showLoadingError()
                }
            }
        }
    }
    
    func logout() {
        UIBlockingProgressHUD.show()
        
        ProfileLogoutService.shared.logout {
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                guard let window = UIApplication.shared.windows.first else {
                    assertionFailure("Ошибка конфигурации окна")
                    return
                }
                
                let splashVC = SplashViewController()
                window.rootViewController = splashVC
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupProfileImageObserver() {
        profileImageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let userInfo = notification.userInfo,
               let avatarURL = userInfo["URL"] as? String {
                self?.view?.updateAvatar(with: avatarURL)
            }
        }
    }
}
