import UIKit
@preconcurrency import WebKit

// MARK: - WebViewConstants
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

// MARK: - WebViewViewControllerDelegate Protocol
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: - WebViewViewController
final class WebViewViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Properties
    weak var delegate: WebViewViewControllerDelegate?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WebViewViewController: viewDidLoad вызван")
        if delegate == nil {
            print("WebViewViewController: Делегат не установлен в viewDidLoad")
        } else {
            print("WebViewViewController: Делегат установлен в viewDidLoad")
        }
        
        loadAuthView()
        webView.navigationDelegate = self
        progressView.progress = 0.1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
        updateProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self,
                               forKeyPath: #keyPath(WKWebView.estimatedProgress),
                               context: nil)
    }
    
    // MARK: - Actions
    @IBAction private func didTapBackButton(_ sender: Any?) {
        guard let delegate = delegate else {
            print("Delegate not installed")
            return
        }
        delegate.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private Methods
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Error: Failed to create URL components")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            showErrorAlert(message: "Error: Failed to create URL from components")
            return
        }
        
        let request = URLRequest(url: url)
//        let websiteDataTypes: Set<String> = [WKWebsiteDataTypeCookies, WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]
//        let date = Date(timeIntervalSince1970: 0)
//        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date) {
//            print("Cookies and cache cleared")
//            self.webView.load(request)
//        }
        clearWebViewData {
            self.webView.load(request)
        }
    }
    
    private func clearWebViewData(completion: @escaping () -> Void) {
        let dataStore = WKWebsiteDataStore.default()
        
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records) {
                print("WebView data cleared")
                completion()
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }
}

// MARK: - WKNavigationDelegate Extension
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            print("WebViewViewController: Код авторизации получен: \(code)")
            if let delegate = delegate {
                print("WebViewViewController: Вызов делегата")
                delegate.webViewViewController(self, didAuthenticateWithCode: code)
            } else {
                print("WebViewViewController: Делегат не установлен")
            }
            decisionHandler(.cancel)
            print("WebViewViewController: WebView не закрываем, ожидаем завершения процесса аутентификации")
            return
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
