//
//  MyPostService.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import FirebaseFirestore
import FirebaseStorage

class MyPostFirestoreService {
    
    private let db = Firestore.firestore()
    
    private let storage = Storage.storage()
    
    func loadPosts(user_idx: String, post_status: String, completion: @escaping ([MyPost]) -> Void){
        db.collection("posts")
            .whereField("user_idx", isEqualTo: user_idx)
            .whereField("post_status", isEqualTo: post_status)
            .order(by: "created_at", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error {
                    print("Error getting errors: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var loadedPosts: [MyPost] = []
                let dispatchGroup = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let postIdx = document.documentID
                    let userIdx = data["user_idx"] as? String ?? ""
                    let postCategory = data["post_category"] as? String ?? ""
                    let postCategoryType = data["post_categoryType"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let postContent = data["post_content"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let wantNum = data["want_num"] as? Int ?? 0
                    let createdAt = (data["created_at"] as? Timestamp)?.dateValue() ?? Date()
                    let schoolIdx = data["school_idx"] as? String ?? ""
                    let postStatus = data["post_status"] as? String ?? ""
                    
                    dispatchGroup.enter()
                    
                    self.loadMyPostImages(postIdx: postIdx){
                        postImage in
                        self.loadMyPostMetrics(postIdx: postIdx){
                            postLikeCnt, postCommentCnt in
                            let post = MyPost(
                                post_idx: postIdx,
                                user_idx: userIdx,
                                post_category: postCategory,
                                post_categoryType: postCategoryType,
                                title: title,
                                post_content: postContent,
                                location: location,
                                want_num: wantNum,
                                post_status: postStatus,
                                created_at: createdAt,
                                school_idx: schoolIdx,
                                postImage_url: postImage ?? "",
                                post_likeCnt: postLikeCnt,
                                post_commentCnt: postCommentCnt
                            )
                            loadedPosts.append(post)
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main){
                    completion(loadedPosts)
                }
                
            }
    }
    
    func loadMyPostImages(postIdx: String, completion: @escaping (String?) -> Void) {
        db.collection("posts").document(postIdx).collection("postImages")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting post images: \(error.localizedDescription)")
                    completion(nil)
                } else if let document = querySnapshot?.documents.first {
                    let data = document.data()
                    let imageUrl = data["image_url"] as? String
                    completion(imageUrl)
                } else {
                    print("No images found for post \(postIdx)")
                    completion(nil)
                }
            }
    }
    
    func loadMyPostMetrics(postIdx: String, completion: @escaping (Int, Int) -> Void){
        let dispatchGroup = DispatchGroup()
        var likeCount = 0
        var totalCommentCount = 0
        
        dispatchGroup.enter()
        db.collection("postLikes")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments{ (querySnapShot, error) in
                likeCount = querySnapShot?.documents.count ?? 0
                dispatchGroup.leave()
            }
        
        dispatchGroup.enter()
        db.collection("posts").document(postIdx).collection("comments")
            .getDocuments { (querySnapshot, error) in
                guard let commentDocs = querySnapshot?.documents else {
                    dispatchGroup.leave()
                    return
                }
                
                totalCommentCount += commentDocs.count // Add comment count
                
                let nestedDispatchGroup = DispatchGroup()
                
                for commentDoc in commentDocs {
                    nestedDispatchGroup.enter()
                    commentDoc.reference.collection("replies").getDocuments { (replySnapshot, replyError) in
                        if let replies = replySnapshot?.documents {
                            totalCommentCount += replies.count // Add replies count
                        }
                        nestedDispatchGroup.leave()
                    }
                }
                
                nestedDispatchGroup.notify(queue: .main) {
                    dispatchGroup.leave()
                }
            }
        
        dispatchGroup.notify(queue: .main) {
            completion(likeCount, totalCommentCount)
        }
    }
    
    func updatePostStatus(postIdx: String, newStatus: String, completion: @escaping (Bool) -> Void) {
        db.collection("posts").document(postIdx).updateData(["post_status": newStatus]) { error in
            if let error = error {
                print("Error updating post status: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Post status updated to \(newStatus) for post \(postIdx)")
                completion(true)
            }
        }
    }
    
    // 게시물 삭제
    func deletePost(postIdx: String, completion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()

        // 1. 댓글 및 대댓글 삭제
        dispatchGroup.enter()
        db.collection("posts").document(postIdx).collection("comments").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for comment in documents {
                    let commentId = comment.documentID
                    
                    // 대댓글 삭제
                    dispatchGroup.enter()
                    self.db.collection("posts")
                        .document(postIdx)
                        .collection("comments")
                        .document(commentId)
                        .collection("replies")
                        .getDocuments { replySnapshot, replyError in
                            if let replies = replySnapshot?.documents {
                                for reply in replies {
                                    reply.reference.delete()
                                }
                            }
                            dispatchGroup.leave()
                        }
                    
                    // 댓글 삭제
                    comment.reference.delete()
                }
            }
            dispatchGroup.leave()
        }

        // 2. 이미지 삭제 (Firestore 및 Storage)
        dispatchGroup.enter()
        db.collection("posts").document(postIdx).collection("postImages").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for document in documents {
                    if let imageUrl = document.data()["image_url"] as? String {
                        // Firebase Storage에서 이미지 삭제
                        let storageRef = self.storage.reference(forURL: imageUrl)
                        dispatchGroup.enter()
                        storageRef.delete { error in
                            if let error = error {
                                print("Error deleting image from Storage: \(error)")
                            }
                            dispatchGroup.leave()
                        }
                    }
                    // Firestore에서 이미지 문서 삭제
                    document.reference.delete()
                }
            }
            dispatchGroup.leave()
        }

        // 3. postLikes 삭제
        dispatchGroup.enter()
        db.collection("postLikes").whereField("post_idx", isEqualTo: postIdx).getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for document in documents {
                    document.reference.delete()
                }
            }
            dispatchGroup.leave()
        }

        // 4. 게시물 삭제
        dispatchGroup.enter()
        db.collection("posts").document(postIdx).delete { error in
            if let error = error {
                print("Error deleting post: \(error)")
            }
            dispatchGroup.leave()
        }

        // 모든 삭제 작업 완료 후 처리
        dispatchGroup.notify(queue: .main) {
            print("Post \(postIdx) and related data deleted successfully")
            completion(true)
        }
    }
}
