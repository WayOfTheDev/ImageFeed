import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage?

    struct ProfileImage: Codable {
        let small: String?
        let medium: String?
        let large: String?
    }

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
