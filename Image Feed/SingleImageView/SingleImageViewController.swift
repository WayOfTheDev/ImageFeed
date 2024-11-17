import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    var imageURL: String? {
        didSet {
            guard isViewLoaded, let imageURL = imageURL else { return }
            loadImage(from: imageURL)
        }
    }

    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.indicatorStyle = .default
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3.0
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .ypBlack
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "nav_back_button_white")
        button.setImage(image, for: .normal)
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.accessibilityIdentifier = "BackButton"
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "share_button")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        button.accessibilityIdentifier = "ShareButton"
        return button
    }()
    
    // MARK: - Constraints for imageView
    private var imageViewWidthConstraint: NSLayoutConstraint?
    private var imageViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let imageURL = imageURL {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ImageView constraints
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            // BackButton constraints
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            
            // ShareButton constraints
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            shareButton.widthAnchor.constraint(equalToConstant: 51),
            shareButton.heightAnchor.constraint(equalToConstant: 51)
        ])
        
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
        imageViewWidthConstraint?.isActive = true
        imageViewHeightConstraint?.isActive = true
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapShareButton() {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Load Image
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("SingleImageViewController: Invalid URL - \(urlString)")
            self.imageView.image = UIImage(systemName: "photo.fill")
            return
        }

        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo"),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    self.updateImageViewConstraints(with: imageResult.image)
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure:
                    self.showError()
                }
            }
    }
    
    // MARK: - Update ImageView Constraints
    private func updateImageViewConstraints(with image: UIImage) {
        imageViewWidthConstraint?.isActive = false
        imageViewHeightConstraint?.isActive = false
        
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: image.size.width)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: image.size.height)
        
        imageViewWidthConstraint?.isActive = true
        imageViewHeightConstraint?.isActive = true
        
        view.layoutIfNeeded()
    }
    
    // MARK: - Show Error Alert
    private func showError() {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self, let urlString = self.imageURL else { return }
            self.loadImage(from: urlString)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Zooming
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard let image = image else { return }
        
        _ = scrollView.minimumZoomScale
        _ = scrollView.maximumZoomScale
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(hScale, vScale)
        
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        
        centerImage()
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size

        let verticalInset = max(0, (scrollViewSize.height - imageSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
