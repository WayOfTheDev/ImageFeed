import UIKit

// MARK: - SegueIdentifiers
enum SegueIdentifiers {
    static let showWebView = "ShowWebView"
}

// MARK: - AuthViewControllerDelegate Protocol
protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

// MARK: - AuthViewController
final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AuthViewController: viewDidLoad вызван")
        
        loginButton.layer.cornerRadius = 16
        loginButton.clipsToBounds = true
        
        configureBackButton()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("AuthViewController: prepare(for:sender:) вызван")
        print("Тип segue.destination: \(type(of: segue.destination))")
        print("Полное имя класса segue.destination: \(NSStringFromClass(type(of: segue.destination)))")
        
        if segue.identifier == SegueIdentifiers.showWebView {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                fatalError("Не удалось подготовить \(SegueIdentifiers.showWebView): не является WebViewViewController")
            }
            print("AuthViewController: Устанавливаем делегат для WebViewViewController")
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - WebViewViewControllerDelegate
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("AuthViewController: Метод webViewViewController вызван с кодом: \(code)")
        print("AuthViewController: Получен код авторизации: \(code)")
        
        oauth2Service.fetchOAuthToken(with: code) { [weak self] result in
            print("Получен результат запроса токена")
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Авторизация успешна, получен токен: \(token)")
                    self?.showAlert(title: "Так держать!", message: "Вы успешно авторизовались!")
                    
                    self?.switchToMainInterface()
                    
                case .failure(let error):
                    print("Ошибка при получении токена: \(error)")
                    self?.showAlert(title: "Ошибка", message: "Не удалось завершить авторизацию: \(error.localizedDescription)")
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
        print("Показ алерта: \(title) - \(message)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true) {
            print("Алерт показан")
        }
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
