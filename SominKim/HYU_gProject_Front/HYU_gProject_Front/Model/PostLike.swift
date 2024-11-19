
//  PostLike.swift : PostLike Table

import Foundation

struct PostLike {
    
    let like_idx: Int // 좋아요 ID
    let post_idx: Int // 게시물 ID (fk)
    let user_idx: Int // 유저 ID (fk)
    var created_at: String // 좋아요 생성일
    
}
