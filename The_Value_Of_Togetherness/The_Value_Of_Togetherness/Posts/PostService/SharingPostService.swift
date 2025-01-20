//
//  SharingPostService.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import FirebaseFirestore

class SharingFirestoreService {
    
    private let db = Firestore.firestore()
    
    // 포스트 불러오기
    func loadPosts(school_idx: String, category: String, completion: @escaping ([SharingPost]) -> Void) {
            db.collection("posts")
                .whereField("school_idx", isEqualTo: school_idx)
                .whereField("post_category", isEqualTo: category)
                .whereField("post_status", in: ["거래가능", "거래완료"])
                .order(by: "created_at", descending: true)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting posts: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    
                    var loadedPosts: [SharingPost] = []
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
                        
                        // 첫 번째 이미지 가져오기
                        self.loadPostImages(postIdx: postIdx) { imageUrl in
                            // 좋아요와 댓글 수 가져오기
                            self.loadPostMetrics(postIdx: postIdx) { likeCount, commentCount, chatRoomCount in
                                let post = SharingPost(
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
                                    postImage_url: imageUrl ?? "",
                                    post_likeCnt: likeCount,
                                    post_commentCnt: commentCount,
                                    active_chatRoomCnt: chatRoomCount
                                )
                                loadedPosts.append(post)
                                dispatchGroup.leave()
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(loadedPosts)
                    }
                }
        }
    
    // 포스트 이미지 가져오기
    func loadPostImages(postIdx: String, completion: @escaping (String?) -> Void) {
        db.collection("posts").document(postIdx).collection("postImages")
            .order(by: "order") // `order`로 정렬
            .limit(to: 1) // 첫 번째 이미지만 가져옴
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting post images: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    let imageUrl = querySnapshot?.documents.first?["image_url"] as? String
                    completion(imageUrl)
                }
            }
    }
    
    // 포스트 메트릭스 (좋아요, 댓글 수) 가져오기
    func loadPostMetrics(postIdx: String, completion: @escaping (Int, Int, Int) -> Void) {
        let dispatchGroup = DispatchGroup()
        var likeCount = 0
        var totalCommentCount = 0
        var activeChatRoomsCount = 0
        
        dispatchGroup.enter()
        db.collection("postLikes")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments { (querySnapshot, error) in
                likeCount = querySnapshot?.documents.count ?? 0
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
        
        // 활성화된 채팅방 수 가져오기
        dispatchGroup.enter()
        db.collection("chattingRooms")
            .whereField("post_idx", isEqualTo: postIdx)
            .whereField("roomState", isEqualTo: true) // roomState가 true인 항목만
            .getDocuments { (querySnapshot, error) in
                activeChatRoomsCount = querySnapshot?.documents.count ?? 0
                dispatchGroup.leave()
            }

        // 모든 데이터를 가져온 후 완료 핸들러 호출
        dispatchGroup.notify(queue: .main) {
            completion(likeCount, totalCommentCount, activeChatRoomsCount)
        }
    }
    
    // 활성화된 채팅방 수 가져오기
    func fetchActiveChatRoomCount(for postIdx: String, completion: @escaping (Int) -> Void) {
        db.collection("chattingRooms")
            .whereField("post_idx", isEqualTo: postIdx)
            .whereField("roomState", isEqualTo: true) // 활성 상태
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching active chat room count: \(error.localizedDescription)")
                    completion(0)
                } else {
                    let activeChatRoomCount = querySnapshot?.documents.count ?? 0
                    completion(activeChatRoomCount)
                }
            }
    }
    
    // 게시물 상태 업데이트
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
}
