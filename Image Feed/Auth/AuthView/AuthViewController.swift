import UIKit
import ProgressHUD

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    // MARK: - Properties
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - Auth logo screen
    private lazy var authLogoImageView: UIImageView = {
        let authLogo = UIImageView()
        authLogo.translatesAutoresizingMaskIntoConstraints = false
        authLogo.image = UIImage(named: "auth_screen_logo")
        return authLogo
    }()
    
    // MARK: - UI Elements
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypWhite
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        button.accessibilityIdentifier = "Authenticate"
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Constraints
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(authLogoImageView)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            
            authLogoImageView.widthAnchor.constraint(equalToConstant: 60),
            authLogoImageView.heightAnchor.constraint(equalToConstant: 60),
            authLogoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            authLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapLoginButton() {
        showWebView()
    }
    
    private func showWebView() {
        let webViewVC = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewVC.presenter = webViewPresenter
        webViewPresenter.view = webViewVC
        webViewVC.delegate = self
        
        webViewVC.modalPresentationStyle = .fullScreen
        present(webViewVC, animated: true, completion: nil)
    }
    
    // MARK: - WebViewViewControllerDelegate Methods
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            self?.handleAuthentication(code: code)
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Handle Authentication
    private func handleAuthentication(code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(_):
                    self.showAlert(title: "Так держать!", message: "Вы успешно авторизовались!")
                    self.switchToMainInterface()
                case .failure(_):
                    self.showAlert(title: "Что-то пошло не так(", message: "Не удалось войти в систему")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func switchToMainInterface() {
        ImagesListService.shared.reset()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Ошибка конфигурации окна")
            return
        }

        let tabBarController = TabBarController()

        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarController
        })
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
