import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
    }

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.67, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "ipad.and.arrow.forward")!
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
        button.addTarget(nil, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties
    private var profileImageObserver: NSObjectProtocol?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.11, blue: 0.13, alpha: 1)

        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)

        setupConstraints()
        updateProfileDetails()

        profileImageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let userInfo = notification.userInfo,
               let avatarURL = userInfo["URL"] as? String {
                self.loadImage(from: avatarURL)
            }
        }
    }

    deinit {
        if let profileImageObserver = profileImageObserver {
            NotificationCenter.default.removeObserver(profileImageObserver)
        }
    }

    // MARK: - Update Profile
    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else {
            return
        }
        
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio

        if let avatarURL = profile.profileImageURL {
            loadImage(from: avatarURL)
        } else {
            loadAvatar(username: profile.username)
        }
    }

    // MARK: - Load Avatar
    private func loadAvatar(username: String) {
        print("Loading avatar for username: \(username)")
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let avatarURL):
                    print("Successfully retrieved avatar URL")
                    self?.loadImage(from: avatarURL)
                case .failure(let error):
                    print("Failed to load avatar: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Load Image с использованием Kingfisher
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            self.avatarImageView.image = UIImage(systemName: "person.crop.circle.badge.exclamationmark")
            return
        }

        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.crop.circle.fill"),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]) { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("Failed to load image with Kingfisher: \(error.localizedDescription)")
                    self.avatarImageView.image = UIImage(systemName: "person.crop.circle.badge.exclamationmark")
                }
            }
    }

    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])

        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 65),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])

        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Actions
    @objc
    private func didTapLogoutButton() {
        // Реализация функционала выхода из аккаунта
    }
}
