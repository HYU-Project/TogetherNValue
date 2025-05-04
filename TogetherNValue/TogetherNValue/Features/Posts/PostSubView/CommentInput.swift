//
//  CommentInput.swift
//  hkkim_front
//
//  Created by 김소민 on 1/10/25.
//

import SwiftUI

struct CommentInput: View {
    var isReplying: Bool
    @Binding var commentText: String
    @Binding var replyText: String
    var onSubmitComment: () -> Void
    var onSubmitReply: () -> Void
    var onCancelReply: () -> Void
    
    var body: some View {
        VStack {
            if isReplying {
                HStack {
                    TextField("답글 입력...", text: $replyText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("작성") {
                        onSubmitReply()
                    }
                    .disabled(replyText.isEmpty)
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    Button("취소") {
                        onCancelReply()
                    }
                    .padding()
                }
                .padding()
            } else {
                HStack {
                    TextField("댓글 입력...", text: $commentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("작성") {
                        onSubmitComment()
                    }
                    .disabled(commentText.isEmpty)
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .background(Color.white)
    }
}
