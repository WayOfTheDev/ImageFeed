import Foundation
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    var isLiked: Bool
    let fullImageURL: String
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        
        self.createdAt = ISO8601DateFormatter.shared.date(from: result.createdAt)
        
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.fullImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
