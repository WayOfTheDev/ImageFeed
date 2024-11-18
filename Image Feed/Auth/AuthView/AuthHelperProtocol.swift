import Foundation

// MARK: - AuthHelperProtocol
protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}
