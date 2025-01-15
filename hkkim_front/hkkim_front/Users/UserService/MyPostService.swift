//
//  MyPostService.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import FirebaseFirestore

class MyPostFirestoreService {
    private let db = Firestore.firestore()
    
    func loadPosts(user_idx: String, post_status: String, completion: @escaping ([MyPost]) -> Void){
        db.collection("posts")
            .whereField("user_idx", isEqualTo: user_idx)
            .whereField("post_status", isEqualTo: post_status)
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
        db.collection("postImages")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments{(querySnapShot, error) in
                if let error {
                    print("Error getting post images: \(error.localizedDescription)")
                    completion(nil)
                }
                else {
                    if let document = querySnapShot?.documents.first {
                        let data = document.data()
                        let imageUrl = data["image_url"] as? String
                        completion(nil)
                    }
                    else {
                        completion(nil)
                    }
                }
            }
    }
    
    func loadMyPostMetrics(postIdx: String, completion: @escaping (Int, Int) -> Void){
        let dispatchGroup = DispatchGroup()
        var likeCount = 0
        var commentCount = 0
        
        dispatchGroup.enter()
        db.collection("postLikes")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments{ (querySnapShot, error) in
                likeCount = querySnapShot?.documents.count ?? 0
                dispatchGroup.leave()
            }
        
        dispatchGroup.enter()
        db.collection("comments")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments{ (querySnapShot, error) in
                commentCount = querySnapShot?.documents.count ?? 0
                dispatchGroup.leave()
            }
        
        dispatchGroup.notify(queue: .main){
            completion(likeCount, commentCount)
        }
    }
}
