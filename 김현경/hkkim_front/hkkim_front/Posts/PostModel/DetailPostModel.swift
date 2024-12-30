//
//  DetailPostModel.swift
//  hkkim_front
//
//  Created by 김소민 on 12/30/24.
//

import Foundation
import FirebaseFirestore

// 게시물
struct PostInfo : Identifiable, Codable {
    var id: String { post_idx }
    let post_idx: String
    let user_idx: String
    var post_category: String
    var post_categoryType: String
    var title: String
    var post_content: String
    var location: String
    var want_num: Int
    var post_status: String
    @ServerTimestamp var created_at: Date? // Firestore Timestamp 자동 변환
    let school_idx: String
    var images: [PostImages]?
}

// 게시물 이미지
struct PostImages: Identifiable, Codable {
    @DocumentID var id: String? // Firestore의 문서 ID
    let post_idx: String
    let image_url: String
}

// 유저
struct UserProperty : Identifiable, Codable {
    var id: String {user_idx}
    let user_idx: String
    let name: String
    let profile_image_url: String?
}

// 댓글
struct Comments : Identifiable, Codable{
    var id: String { comment_idx }
    let comment_idx: String
    let user_idx: String
    let post_idx: String
    var comment_content: String
    var comment_created_at: Date
    var replies: [Replies]?
}

// 대댓글
struct Replies : Identifiable, Codable{
    var id: String { reply_idx }
    let reply_idx: String
    let user_idx: String
    let reply_content: String
    let reply_created_at: Date
    let comment_idx: String
}



