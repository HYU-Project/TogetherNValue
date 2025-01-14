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
                                postImage_url: imageUrl ?? "", // 이미지 URL 추가
                                post_likeCnt: 0, // 좋아요 및 댓글 수 초기값
                                post_commentCnt: 0
                            )
                            loadedPosts.append(post)
                            dispatchGroup.leave()
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
    func loadPostMetrics(postIdx: String, completion: @escaping (Int, Int) -> Void) {
        let dispatchGroup = DispatchGroup()
        var likeCount = 0
        var totalCommentCount = 0
        
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
        
        dispatchGroup.notify(queue: .main) {
            completion(likeCount, totalCommentCount)
        }
    }
}
