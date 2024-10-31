import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    let profileImageURL: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        self.name = result.name ?? "No name"
        self.loginName = "@\(result.username)"
        self.bio = result.bio ?? "В процессе разработки"
        self.profileImageURL = result.profileImage?.large
    }
}
