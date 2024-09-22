//
//  ProfileViewController.swift
//  Image Feed
//
//  Created by D. K. on 11.09.24.
//

//import UIKit
//
//final class ProfileViewController: UIViewController {
//    @IBOutlet private var avatarImageView: UIImageView!
//    @IBOutlet private var nameLabel: UILabel!
//    @IBOutlet private var loginNameLabel: UILabel!
//    @IBOutlet private var descriptionLabel: UILabel!
//
//    @IBOutlet private var logoutButton: UIButton!
//
//    @IBAction private func didTapLogoutButton() {
//    }
//}


import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - UI Elements

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.67, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "ipad.and.arrow.forward")!
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)
        button.addTarget(nil, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.11, blue: 0.13, alpha: 1)

        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)

        setupConstraints()
    }

    // MARK: - Constraints Setup

    private func setupConstraints() {
        // avatarImageView Constraints
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])

        // logoutButton Constraints
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // nameLabel Constraints
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])

        // loginNameLabel Constraints
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])

        // descriptionLabel Constraints
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
