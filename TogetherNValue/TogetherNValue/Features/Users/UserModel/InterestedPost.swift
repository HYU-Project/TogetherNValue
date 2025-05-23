//
//  MyPost.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import Foundation

struct InterestedPost: Identifiable {
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
    var post_likeCnt: Int // 좋아요 수
    var post_commentCnt: Int // 댓글 수
}
