import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
        ProgressHUD.mediaSize = 51
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
