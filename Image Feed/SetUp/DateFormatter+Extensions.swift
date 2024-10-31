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
