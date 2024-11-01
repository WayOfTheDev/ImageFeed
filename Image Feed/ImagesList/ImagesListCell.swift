import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - UI Elements
    let cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Aspect Ratio Constraint
    private var aspectRatioConstraint: NSLayoutConstraint?
    
    // MARK: - Parameters like button tapped
    var onLikeButtonTapped: (() -> Void)?
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGradient()
        setupLikeButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = .ypBlack
        selectionStyle = .none
        
        contentView.addSubview(cellImage)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        contentView.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            // cellImage constraints
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // likeButton constraints
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalTo: likeButton.widthAnchor),
            
            // dateLabel constraints
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),
            
            // gradientView constraints
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Setup Gradient
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.ypBlack0.cgColor,
            UIColor.ypBlack20.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5393]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - Prepare for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = UIImage(systemName: "photo")
        likeButton.setImage(UIImage(named: "like_button_off"), for: .normal)
        dateLabel.text = nil
        onLikeButtonTapped = nil
        
        if let aspectRatioConstraint = aspectRatioConstraint {
            cellImage.removeConstraint(aspectRatioConstraint)
            self.aspectRatioConstraint = nil
        }
    }
    
    // MARK: - Setup Like Button
    private func setupLikeButton() {
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
    }
    
    // MARK: - Did Tap Like Button
    @objc private func didTapLikeButton() {
        onLikeButtonTapped?()
    }
    
    // MARK: - Set Is Liked
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    // MARK: - Configure Aspect Ratio
    func configureAspectRatio(with size: CGSize) {
        let aspectRatio = size.width / size.height
        
        aspectRatioConstraint = cellImage.heightAnchor.constraint(equalTo: cellImage.widthAnchor, multiplier: 1 / aspectRatio)
        aspectRatioConstraint?.priority = UILayoutPriority(999)
        aspectRatioConstraint?.isActive = true
    }
}
