import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var gradientView: UIView!
    
    private let gradientLayer = CAGradientLayer()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
        setupDateLabel()
        contentView.bringSubviewToFront(gradientView)
        gradientView.isHidden = false
        gradientView.alpha = 1
        contentView.alpha = 1
        gradientView.backgroundColor = .clear
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
        
    func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5393]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
        
    func setupDateLabel() {
        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
}
