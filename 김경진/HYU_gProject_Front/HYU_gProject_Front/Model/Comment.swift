
//  Comment.swift : Comment Table

import Foundation

struct Comment : Identifiable{
    let id = UUID() 
    let comment_idx: Int
    let user_idx: Int // 작성자 ID (fk)
    let post_idx: Int // 게시물 ID (fk)
    var comment_content: String // 댓글 내용
    var comment_created_at: String // 댓글 생성일
    var replies: [Reply] // 대댓글 리스트
    // 초기화 함수
}
