import Foundation

struct ParticiaptePost: Identifiable {
    var id: String { post_idx }
    let post_idx: String
    let user_idx: String
    let post_category: String
    let post_categoryType: String
    let title: String
    let post_content: String
    let location: String
    let want_num: Int
    let post_status: String
    let created_at: Date
    let school_idx: String
    let postImage_url: String?  // 포스트 이미지 URL
    let roomState: Bool
}

