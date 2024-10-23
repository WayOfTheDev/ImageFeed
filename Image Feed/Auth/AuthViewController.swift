import UIKit

// MARK: - SegueIdentifiers
enum SegueIdentifiers {
    static let showWebView = "ShowWebView"
}

// MARK: - AuthViewController
final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var loginButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 16
        loginButton.clipsToBounds = true
        
        configureBackButton()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showWebView {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                fatalError("Не удалось подготовить \(SegueIdentifiers.showWebView): не является WebViewViewController")
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - WebViewViewControllerDelegate
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(_):
                    self?.showAlert(title: "Так держать!", message: "Вы успешно авторизовались!")
                    self?.switchToMainInterface()
                case .failure(_):
                    self?.showAlert(title: "Что-то пошло не так(", message: "Не удалось войти в систему")
                }
            }
        }
    }

    // MARK: - Private Methods
    private func configureBackButton() {
        navigationController?.setCustomBackButton(imageName: "nav_back_button", tintColor: UIColor(named: "ypBlack")!)
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

// MARK: - UINavigationController Extension
extension UINavigationController {
    func setCustomBackButton(imageName: String, tintColor: UIColor) {
        navigationBar.backIndicatorImage = UIImage(named: imageName)
        navigationBar.backIndicatorTransitionMaskImage = UIImage(named: imageName)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = tintColor
    }
}
