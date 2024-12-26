//
//  PurchasePostService.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import FirebaseFirestore

class PurchaseFirestoreService {
    
    private let db = Firestore.firestore()
    
    // post 불러오기
    func loadPosts(school_idx: String, category: String, completion: @escaping ([PurchasePost]) -> Void) {
        db.collection("posts")
            .whereField("school_idx", isEqualTo: school_idx)
            .whereField("post_category", isEqualTo: category)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting posts: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var loadedPosts: [PurchasePost] = []
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
                    
                    // 이미지와 메트릭을 동시에 불러오기
                    self.loadPostImages(postIdx: postIdx) { postImage in
                        self.loadPostMetrics(postIdx: postIdx) { postLikeCnt, postCommentCnt in
                            let post = PurchasePost(
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
                                school_idx: school_idx,
                                postImage_url: postImage ?? "",
                                post_likeCnt: postLikeCnt,
                                post_commentCnt: postCommentCnt
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
        db.collection("postImages")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting post images: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    if let document = querySnapshot?.documents.first {
                        let data = document.data()
                        let imageUrl = data["image_url"] as? String
                        completion(imageUrl) // Firestore에서 가져온 URL 반환
                    } else {
                        completion(nil)
                    }
                }
            }
    }
    
    // 포스트 메트릭스 (좋아요, 댓글 수) 가져오기
    func loadPostMetrics(postIdx: String, completion: @escaping (Int, Int) -> Void) {
        let dispatchGroup = DispatchGroup()
        var likeCount = 0
        var commentCount = 0
        
        dispatchGroup.enter()
        db.collection("postLikes")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments { (querySnapshot, error) in
                likeCount = querySnapshot?.documents.count ?? 0
                dispatchGroup.leave()
            }
        
        dispatchGroup.enter()
        db.collection("comments")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments { (querySnapshot, error) in
                commentCount = querySnapshot?.documents.count ?? 0
                dispatchGroup.leave()
            }
        
        dispatchGroup.notify(queue: .main) {
            completion(likeCount, commentCount)
        }
    }
}
