import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupAppearance()
    }
    
    // MARK: - setupViewControllers
    private func setupViewControllers() {
        let imagesListViewController = ImagesListViewController()
        let imagesListPresenter = ImagesListPresenter()
        
        imagesListViewController.configure(imagesListPresenter)
        
        let imagesIcon = UIImage(named: "tab_editorial_active")?.withRenderingMode(.alwaysTemplate)
        let imagesSelectedIcon = UIImage(named: "tab_editorial_selected")?.withRenderingMode(.alwaysTemplate)
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: imagesIcon,
            selectedImage: imagesSelectedIcon
        )
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)
        
        let profileIcon = UIImage(named: "tab_profile_active")?.withRenderingMode(.alwaysTemplate)
        let profileSelectedIcon = UIImage(named: "tab_profile_selected")?.withRenderingMode(.alwaysTemplate)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: profileIcon,
            selectedImage: profileSelectedIcon
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
    // MARK: - setupAppearance
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlack

        appearance.stackedLayoutAppearance.selected.iconColor = .ypWhite
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.ypWhite]

        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.isTranslucent = false

        tabBar.tintColor = .ypWhite
        tabBar.unselectedItemTintColor = .gray
    }
}
