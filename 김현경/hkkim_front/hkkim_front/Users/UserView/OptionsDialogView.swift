//
//  OptionsDialogView.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import SwiftUI

struct OptionsDialogView: View {
    var selectedPost: MyPost?
    var showingOptions: Binding<Bool>
    var updatePostStatus: (MyPost) -> Void
    var deletePost: (MyPost) -> Void
    
    var body: some View {
        VStack {
            if let selectedPost = selectedPost {
                
                if selectedPost.post_status == "거래중" {
                    Button("거래 완료") {
                        updatePostStatus(selectedPost)
                        showingOptions.wrappedValue = false
                    }
                }
                
                Button("게시글 삭제") {
                    deletePost(selectedPost)
                    showingOptions.wrappedValue = false
                }
            }
            
            Button("닫기", role: .cancel) {
                showingOptions.wrappedValue = false
            }
        }
    }
}

