import Foundation

// MARK: - Constants
enum Constants {
    static let accessKey = "_Yn_e5C5LN14g5mGYLDwAlbyBRWy_yDtJE-WLtH3lBE"
    static let secretKey = "JjXce_pz5PxwMUIlUiBmgo-CXZ114n6NvQHDks4VrGg"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashTokenURL = "https://unsplash.com/oauth/token"
}

// MARK: - WebViewConstants
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashAuthPath = "/oauth/authorize/native"
}
