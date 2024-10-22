import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    
    // MARK: - UI Elements
    private let splashImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: ".ypBlack")
        
        view.addSubview(splashImageView)
        
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthenticationStatus()
    }
    
    // MARK: - Private Methods
    private func checkAuthenticationStatus() {
        // oauth2TokenStorage.token = nil  // оставляю для ситуаций, когда потребуется полный перезапуск приложения
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    private func fetchProfile(token: String) {
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()

                guard let self = self else { return }

                switch result {
                case .success(let profile):
                    self.fetchProfileImage(username: profile.username)
                    self.switchToMainInterface()

                case .failure(let error):
                    self.showErrorAlert(with: error.localizedDescription)
                }
            }
        }
    }

    private func fetchProfileImage(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("Failed to fetch profile image URL: \(error.localizedDescription)")
            }
        }
    }

    private func showErrorAlert(with message: String) {
        let alertController = UIAlertController(title: "Ошибка входа", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    private func switchToMainInterface() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Ошибка конфигурации окна")
                return
            }
            
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = tabBarController
            })
        }
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            return
        }
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true, completion: nil)
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) {
            self.fetchProfile(token: OAuth2TokenStorage.shared.token ?? "")
        }
    }
}
