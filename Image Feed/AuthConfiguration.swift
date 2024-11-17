import Foundation

// MARK: - AuthConfiguration
struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    let unsplashTokenURL: String

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: "_Yn_e5C5LN14g5mGYLDwAlbyBRWy_yDtJE-WLtH3lBE",
            secretKey: "JjXce_pz5PxwMUIlUiBmgo-CXZ114n6NvQHDks4VrGg",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            defaultBaseURL: URL(string: "https://api.unsplash.com")!,
            authURLString: "https://unsplash.com/oauth/authorize",
            unsplashTokenURL: "https://unsplash.com/oauth/token"
        )
    }
}
