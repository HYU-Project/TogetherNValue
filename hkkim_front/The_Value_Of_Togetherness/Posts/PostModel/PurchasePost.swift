//
//  PurchasePost.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import Foundation

struct PurchasePost : Identifiable {
    var id: String { post_idx }
    let post_idx: String
    let user_idx: String
    let post_category: String
    let post_categoryType: String
    let title: String
    let post_content: String
    let location: String
    let want_num: Int
    var post_status: String
    let created_at: Date
    let school_idx: String
    let postImage_url: String?  // 포스트 이미지 URL
    var post_likeCnt: Int // 좋아요 수
    var post_commentCnt: Int // 댓글 수
    var active_chatRoomCnt: Int // 1:1 거래 완료 수
}
