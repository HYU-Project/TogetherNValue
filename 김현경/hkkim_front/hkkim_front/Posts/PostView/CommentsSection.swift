//
//  CommentsSection.swift
//  hkkim_front
//
//  Created by 김소민 on 1/10/25.
//

import SwiftUI

struct CommentsSection: View {
    @EnvironmentObject var userManager : UserManager
    @State private var editingCommentId: String? = nil   // 수정 중인 댓글 ID
    @State private var editingReplyId: String? = nil     // 수정 중인 대댓글 ID
    @State private var editingContent: String = ""       // 수정 중인 내용
    @Binding var comments: [Comments]
    
    var post_idx: String
    var onReply: (String) -> Void
    
    private let firestoreService = DetailPostFirestoreService()
    
    private func updateComment(commentId: String, newContent: String) {
        let commentPath = "posts/\(post_idx)/comments/\(commentId)"
        
        firestoreService.updateDocument(path: commentPath, data: ["comment_content": newContent]) { result in
            switch result {
            case .success:
                if let index = comments.firstIndex(where: { $0.comment_idx == commentId }) {
                    comments[index].comment_content = newContent // 배열 업데이트
                }
                print("Comment updated successfully")
            case .failure(let error):
                print("Failed to update comment: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateReply(commentId: String, replyId: String, newContent: String) {
        let replyPath = "posts/\(post_idx)/comments/\(commentId)/replies/\(replyId)"
        
        firestoreService.updateDocument(path: replyPath, data: ["reply_content": newContent]) { result in
            switch result {
            case .success:
                if let commentIndex = comments.firstIndex(where: { $0.comment_idx == commentId }),
                   let replyIndex = comments[commentIndex].replies?.firstIndex(where: { $0.reply_idx == replyId }) {
                    comments[commentIndex].replies?[replyIndex].reply_content = newContent
                }
                print("Reply updated successfully")
            case .failure(let error):
                print("Failed to update reply: \(error.localizedDescription)")
            }
        }
    }

    
    private func deleteComment(commentId: String){
        let commentPath = "posts/\(post_idx)/comments/\(commentId)"
        let repliesPath = "posts/\(post_idx)/comments/\(commentId)/replies"
        
        // Firestore에서 댓글 문서 삭제
        firestoreService.deleteCollection(path: repliesPath) { result in
            switch result {
            case .success:
                // 댓글 삭제
                firestoreService.deleteDocument(path: commentPath) { result in
                    switch result {
                    case .success:
                        if let index = comments.firstIndex(where: { $0.comment_idx == commentId }) {
                            comments.remove(at: index) // 로컬에서도 제거
                        }
                        print("Comment and its replies deleted successfully")
                    case .failure(let error):
                        print("Failed to delete comment: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Failed to delete replies: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteReply(commentId: String, replyId: String){
        
        let replyPath = "posts/\(post_idx)/comments/\(commentId)/replies/\(replyId)"
        // Firestore에서 대댓글 삭제
            firestoreService.deleteDocument(path: replyPath) { result in
                switch result {
                case .success:
                    print("Reply deleted successfully")
                    if let commentIndex = comments.firstIndex(where: { $0.comment_idx == commentId }),
                       let replyIndex = comments[commentIndex].replies?.firstIndex(where: { $0.reply_idx == replyId }) {
                        comments[commentIndex].replies?.remove(at: replyIndex)
                    }
                case .failure(let error):
                    print("Failed to delete reply: \(error.localizedDescription)")
                }
            }
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
                            // 댓글 수정 중인지 확인
                            if editingCommentId == comment.comment_idx {
                                
                                TextField("댓글 수정", text: $editingContent)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("저장") {
                                    updateComment(commentId: comment.comment_idx, newContent: editingContent)
                                    editingCommentId = nil // 수정 완료
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                Button("취소") {
                                    editingCommentId = nil // 수정 취소
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            } else {
                                Text(comment.comment_content)
                                    .font(.body)
                                
                                if comment.user_idx == userManager.userId {
                                    HStack {
                                        Button(action: {
                                            editingCommentId = comment.comment_idx
                                            editingContent = comment.comment_content // 기존 내용 불러오기
                                        }) {
                                            Text("수정")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Button(action: {
                                            deleteComment(commentId: comment.comment_idx)
                                        }) {
                                            Text("삭제")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            onReply(comment.comment_idx)
                        }) {
                            Text("댓글 달기")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.blue)
                        }
                        
                        if let replies = comment.replies {
                            ForEach(replies) { reply in
                                HStack {
                                    if editingReplyId == reply.reply_idx {
                                        
                                        TextField("대댓글 수정", text: $editingContent)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                                        Button("저장") {
                                            updateReply(commentId: comment.comment_idx, replyId: reply.reply_idx, newContent: editingContent)
                                            editingReplyId = nil // 수정 완료
                                        }
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        Button("취소") {
                                            editingReplyId = nil // 수정 취소
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    } else {
                                        
                                        Text("ㄴ\(reply.reply_content)")
                                            .font(.body)
                                        
                                        if reply.user_idx == userManager.userId {
                                            HStack{
                                                Button(action: {
                                                    editingReplyId = reply.reply_idx
                                                    editingContent = reply.reply_content // 기존 내용 불러오기
                                                }){
                                                    Text("수정")
                                                        .font(.caption)
                                                        .bold()
                                                        .foregroundColor(.blue)
                                                }
                                                
                                                Button(action: {
                                                    deleteReply(commentId: comment.comment_idx, replyId: reply.reply_idx)
                                                }){
                                                    Text("삭제")
                                                        .font(.caption)
                                                        .bold()
                                                        .foregroundColor(.red)
                                                }
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
