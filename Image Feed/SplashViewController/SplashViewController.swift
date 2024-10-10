import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service()
    private let showAuthenticationScreenSegueIdentifier = "authScreen"
    
    // MARK: - Lifecycle Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthenticationStatus()
    }
    
    // MARK: - Private Methods
    private func checkAuthenticationStatus() {
        oauth2TokenStorage.token = nil  // для теста с очисткой токена
        if oauth2TokenStorage.token != nil {
            print("Токен найден, переход на главный интерфейс")
            switchToMainInterface()
        } else {
            print("Токен не найден, запуск авторизации")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToMainInterface() {
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

// MARK: - SplashViewController Extension
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authViewController = navigationController.viewControllers.first as? AuthViewController else {
                fatalError("Не удалось подготовить \(showAuthenticationScreenSegueIdentifier)")
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate Extension
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(with: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToMainInterface()
            case .failure(let error):
                print("Ошибка аутентификации: \(error.localizedDescription)")
            }
        }
    }
}
