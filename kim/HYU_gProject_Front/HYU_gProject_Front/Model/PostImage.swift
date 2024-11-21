//  Post_images.swift : Post_images Table

import Foundation

struct PostImage: Identifiable {
    let id = UUID()
    let image_idx: Int // 게시글 이미지 ID
    let post_idx: Int // 게시글 ID (fk)
    var image_url: String // 이미지 URL
    
}
