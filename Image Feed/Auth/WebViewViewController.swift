import UIKit
@preconcurrency import WebKit

// MARK: - WebViewViewController
final class WebViewViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Properties
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAuthView()
        webView.navigationDelegate = self
        progressView.progress = 0.1
        
        observeEstimatedProgress()
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
    
    private func observeEstimatedProgress() {
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let self = self else { return }
            self.updateProgress()
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
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
            if let delegate = delegate {
                delegate.webViewViewController(self, didAuthenticateWithCode: code)
            } else {
                print("WebViewViewController: Делегат не установлен")
            }
            decisionHandler(.cancel)
            return
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == WebViewConstants.unsplashAuthPath,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
