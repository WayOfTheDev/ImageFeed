import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - Private method
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.backgroundColor = .ypBlack
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        return tableView
    }()
    
    var photos: [Photo] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObservers()
        
        if OAuth2TokenStorage.shared.token != nil {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    // MARK: - Setup UI
    private func setupTableView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Setup Observers
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveImagesListServiceChange), name: ImagesListService.didChangeNotification, object: nil)
    }
    
    // MARK: - Notification Handler
    private var isUpdatingTableView = false

    @objc private func didReceiveImagesListServiceChange() {
        guard !isUpdatingTableView else { return }
        isUpdatingTableView = true
        DispatchQueue.main.async {
            self.updateTableViewAnimated()
            self.isUpdatingTableView = false
        }
    }
    
    // MARK: - Update animated table
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = ImagesListService.shared.photos
        let newCount = newPhotos.count
        let addedCount = newCount - oldCount

        photos = newPhotos

        if oldCount == 0 {
            tableView.reloadData()
        } else if addedCount > 0 {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }

            tableView.performBatchUpdates({
                tableView.insertRows(at: indexPaths, with: .automatic)
            }, completion: nil)
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    private func showSingleImage(at indexPath: IndexPath) {
        let singleImageVC = SingleImageViewController()
        let photo = photos[indexPath.row]
        singleImageVC.imageURL = photo.fullImageURL
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        let photo = photos[indexPath.row]
        configureCell(for: imageListCell, with: photo, at: indexPath)

        return imageListCell
    }
}

// MARK: - Configuration
extension ImagesListViewController {
    func configureCell(for cell: ImagesListCell, with photo: Photo, at indexPath: IndexPath) {
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = DateFormatter.sharedMedium.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }

        cell.setIsLiked(photo.isLiked)
        cell.configureAspectRatio(with: photo.size)

        if let thumbURL = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: thumbURL,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]) { [weak self] result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            self?.tableView.beginUpdates()
                            self?.tableView.endUpdates()
                        }
                    case .failure(let error):
                        print("ImagesListViewController: Failed to load image - \(error.localizedDescription)")
                        cell.cellImage.image = UIImage(systemName: "photo.fill")
                    }
                }
        } else {
            cell.cellImage.image = UIImage(systemName: "photo.fill")
        }
        
        cell.onLikeButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.handleLikeButtonTap(for: photo)
        }
    }
    
    // MARK: - Like button tapped
    private func handleLikeButtonTap(for photo: Photo) {
        UIBlockingProgressHUD.show()
        
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success():
                if let index = self?.photos.firstIndex(where: { $0.id == photo.id }) {
                    let updatedPhoto = self?.photos[index]
                    if let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImagesListCell {
                        cell.setIsLiked(updatedPhoto?.isLiked ?? false)
                    }
                }
            case .failure(_):
                self?.showErrorAlert(message: "Не удалось изменить статус лайка. Попробуйте еще раз.")
            }
        }
    }
    
    // MARK: - Error alert
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    // MARK: - Cell selection processing
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImage(at: indexPath)
    }

    // MARK: - Pagination (load next page)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}
