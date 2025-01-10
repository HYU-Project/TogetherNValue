//
//  CommentsSection.swift
//  hkkim_front
//
//  Created by 김소민 on 1/10/25.
//

import SwiftUI

struct CommentsSection: View {
    @EnvironmentObject var userManager : UserManager
    var comments: [Comments]
    var onReply: (String) -> Void
    
    private let firestoreService = DetailPostFirestoreService()
    
    private func updateComment(){
        
    }
    
    private func updateReplu(){
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("댓글")
                .font(.title3)
                .bold()
                .padding(.bottom, 8)
            
            if comments.isEmpty {
                Text("댓글이 없습니다.")
                    .foregroundColor(.gray)
            } else {
                ForEach(comments) { comment in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(comment.comment_content)
                                .font(.body)
                            
                            if comment.user_idx == userManager.userId {
                                HStack{
                                    Button(action: {
                                        
                                    }){
                                        Text("수정")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Button(action: {
                                        
                                    }){
                                        Text("삭제")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            onReply(comment.comment_idx)
                        }) {
                            Text("댓글 달기")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if let replies = comment.replies {
                            ForEach(replies) { reply in
                                HStack {
                                    Text("ㄴ\(reply.reply_content)")
                                        .font(.body)
                                    
                                    if reply.user_idx == userManager.userId {
                                        HStack{
                                            Button(action: {
                                                
                                            }){
                                                Text("수정")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            Button(action: {
                                                
                                            }){
                                                Text("삭제")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                                .padding(.leading, 15)
                                
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
    }
}
