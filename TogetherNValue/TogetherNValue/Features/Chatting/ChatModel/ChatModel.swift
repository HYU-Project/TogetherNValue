import Foundation

struct FetchPostInfo {
    var title: String
    var location: String
    var post_status: String
}

struct PostImage: Identifiable {
    var id: String?
    var image_url: String
}

struct Message: Identifiable {
    var id: String?
    let senderID: String
    let text: String
    let isCurrentUser: Bool
    let timestamp: Date
    let imageUrl: String?
    var isUploading: Bool = false
}
