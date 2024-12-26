//
//  MyPost.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import Foundation

struct MyPost: Identifiable {
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
    let postImage_url: String?
    var post_likeCnt: Int
    var post_commentCnt: Int
}
