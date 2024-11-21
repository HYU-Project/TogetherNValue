
//  Reply.swift

import Foundation

struct Reply: Identifiable {
    let id = UUID()
    let reply_idx: Int
    let user_idx: Int // 대댓글 작성자 ID (fk)
    let reply_content: String // 대댓글 내용
    let reply_created_at: String // 대댓글 생성일
}
