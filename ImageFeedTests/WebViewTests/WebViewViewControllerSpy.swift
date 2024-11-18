import Foundation
@testable import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled: Bool = false
    var loadedRequest: URLRequest?

    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?

    func load(request: URLRequest) {
        loadRequestCalled = true
        loadedRequest = request
    }

    func setProgressValue(_ newValue: Float) {}

    func setProgressHidden(_ isHidden: Bool) {}
}
