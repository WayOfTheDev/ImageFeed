import Foundation

struct ProfileResult: Codable {
    let username: String
    let name: String?
    let bio: String?
    let profileImage: ProfileImage?

    enum CodingKeys: String, CodingKey {
        case username, name, bio
        case profileImage = "profile_image"
    }
    
    struct ProfileImage: Codable {
        let small: String?
        let medium: String?
        let large: String?
    }
}
