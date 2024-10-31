import UIKit

extension UIColor {
    static let ypBlack: UIColor = {
        guard let color = UIColor(named: "YP Black") else {
            fatalError("Цвет 'ypBlack' не найден в Assets.xcassets")
        }
        return color
    }()
    
    static let ypWhite: UIColor = {
        guard let color = UIColor(named: "YP White") else {
            fatalError("Цвет 'ypWhite' не найден в Assets.xcassets")
        }
        return color
    }()
    
    static let ypGray: UIColor = {
        guard let color = UIColor(named: "YP Grey") else {
            fatalError("Цвет 'ypGray' не найден в Assets.xcassets")
        }
        return color
    }()
    
    static let ypBlack0: UIColor = {
        guard let color = UIColor(named: "YP Black 0") else {
            fatalError("Цвет 'ypBlack0' не найден в Assets.xcassets")
        }
        return color
    }()
    
    static let ypBlack20: UIColor = {
        guard let color = UIColor(named: "YP Black 20") else {
            fatalError("Цвет 'ypBlack20' не найден в Assets.xcassets")
        }
        return color
    }()
}
