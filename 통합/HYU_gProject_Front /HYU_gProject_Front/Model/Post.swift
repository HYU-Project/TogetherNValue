
//  Post.swift : post table

import Foundation

struct Post: Identifiable {
    let id = UUID()
    var post_idx: Int
    let user_idx: Int // users의 fk
    var post_category: String
    var post_categoryType: String
    var title: String
    var post_content: String
    var location: String
    var want_num: Int
    var post_status: String
    var created_at: String
    
    var postImages: [PostImage] // 이미지 URL들
    var post_likeCnt: Int // 좋아요 수
    var post_commentCnt: Int // 댓글 수
}
