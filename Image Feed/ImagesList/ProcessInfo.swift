import Foundation

extension ProcessInfo {
    var isUITest: Bool {
        return self.arguments.contains("testMode")
    }
}
