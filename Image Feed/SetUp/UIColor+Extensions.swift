import UIKit

extension UIColor {
    static let ypBlack: UIColor = {
        guard let color = UIColor(named: "YP Black") else {
            assertionFailure("Цвет 'YP Black' не найден в Assets.xcassets")
            return .black
        }
        return color
    }()
    
    static let ypWhite: UIColor = {
        guard let color = UIColor(named: "YP White") else {
            assertionFailure("Цвет 'YP White' не найден в Assets.xcassets")
            return .white
        }
        return color
    }()
    
    static let ypGray: UIColor = {
        guard let color = UIColor(named: "YP Grey") else {
            assertionFailure("Цвет 'YP Grey' не найден в Assets.xcassets")
            return .gray
        }
        return color
    }()
    
    static let ypBlack0: UIColor = {
        guard let color = UIColor(named: "YP Black 0") else {
            assertionFailure("Цвет 'YP Black 0' не найден в Assets.xcassets")
            return .black
        }
        return color
    }()
    
    static let ypBlack20: UIColor = {
        guard let color = UIColor(named: "YP Black 20") else {
            assertionFailure("Цвет 'YP Black 20' не найден в Assets.xcassets")
            return .black
        }
        return color
    }()
}
