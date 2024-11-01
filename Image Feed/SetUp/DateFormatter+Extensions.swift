import Foundation

extension DateFormatter {
    // MARK: - Singleton
    static let sharedMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

extension ISO8601DateFormatter {
    // MARK: - Singleton
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
}
