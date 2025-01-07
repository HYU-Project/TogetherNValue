//
//  InterestedPostService.swift
//  hkkim_front
//
//  Created by 김소민 on 1/5/25.
//

import FirebaseFirestore

class InterestedPostService {
    let db = Firestore.firestore()

    // 유저가 찜한 게시물 가져오기
    func fetchInterestedPosts(for userId: String, completion: @escaping (Result<[InterestedPost], Error>) -> Void) {
        print("Fetching interested posts for userId: \(userId)")
        db.collection("postLikes")
            .whereField("user_idx", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching postLikes: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No postLikes found for userId: \(userId)")
                    completion(.success([]))
                    return
                }

                // post_idx 목록 추출
                let postIds = documents.compactMap { $0.data()["post_idx"] as? String }
                print("Fetched postIds: \(postIds)")

                guard !postIds.isEmpty else {
                    print("No postIds found for userId: \(userId)")
                    completion(.success([]))
                    return
                }

                // posts 컬렉션에서 post_idx와 일치하는 데이터 가져오기
                self.fetchPosts(by: postIds, completion: completion)
            }
    }

    // post_idx로 posts 정보 가져오기
    private func fetchPosts(by postIds: [String], completion: @escaping (Result<[InterestedPost], Error>) -> Void) {
        print("Fetching posts with postIds: \(postIds)")
        db.collection("posts")
            .whereField(FieldPath.documentID(), in: postIds)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No posts found for postIds: \(postIds)")
                    completion(.success([]))
                    return
                }

                print("Fetched post documents: \(documents.map { $0.data() })")

                let posts: [InterestedPost] = documents.compactMap { document in
                    let data = document.data()
                    print("Processing post document: \(data)")
                    
                    let postIdx = document.documentID
                    
                    guard
                        let userIdx = data["user_idx"] as? String,
                        let postCategory = data["post_category"] as? String,
                        let postCategoryType = data["post_categoryType"] as? String,
                        let title = data["title"] as? String,
                        let postContent = data["post_content"] as? String,
                        let location = data["location"] as? String,
                        let wantNum = data["want_num"] as? Int,
                        let postStatus = data["post_status"] as? String,
                        let createdAt = (data["created_at"] as? Timestamp)?.dateValue(),
                        let schoolIdx = data["school_idx"] as? String
                    else {
                        print("Error parsing post document: \(data)")
                        return nil
                    }

                    // postImages 배열에서 첫 번째 이미지 가져오기
                    let postImages = data["postImages"] as? [String]
                    let postImageUrl = postImages?.first ?? "" // 첫 번째 이미지 또는 기본값
                    
                    let postLikeCnt = data["post_likeCnt"] as? Int ?? 0
                    let postCommentCnt = data["post_commentCnt"] as? Int ?? 0

                    return InterestedPost(
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
                        postImage_url: postImageUrl, // 단일 이미지 URL
                        post_likeCnt: postLikeCnt,
                        post_commentCnt: postCommentCnt
                    )
                }

                print("Parsed posts: \(posts)")
                completion(.success(posts))
            }
    }


    // 하위 컬렉션에서 첫 번째 이미지 가져오기
    private func loadPostImage(postIdx: String, completion: @escaping (String?) -> Void) {
        db.collection("postImages")
            .whereField("post_idx", isEqualTo: postIdx)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching postImages: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No postImages found for postIdx: \(postIdx)")
                    completion(nil)
                    return
                }

                let imageUrl = document.data()["image_url"] as? String
                completion(imageUrl)
            }
    }
    
    func togglePostLike(postIdx: String, userIdx: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void){
            
            let collection = db.collection("postLikes")
            
            if isLiked { // 찜하기 취소
                collection
                    .whereField("post_idx", isEqualTo: postIdx)
                    .whereField("user_idx", isEqualTo: userIdx)
                    .getDocuments{snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        guard let documents = snapshot? .documents else {
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                            return
                        }
                        
                        for document in documents {
                            document.reference.delete(){
                                error in
                                if let error = error {
                                    completion(.failure(error))
                                }
                                else {
                                    completion(.success(()))
                                }
                            }
                        }
                    }
            }
            else { // 찜하기
                let data: [String : Any] = [
                    "post_idx" : postIdx,
                    "user_idx" : userIdx,
                    "created_at": FieldValue.serverTimestamp()
                ]
                
                collection.addDocument(data: data){ error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    else {
                        completion(.success(()))
                    }
                    
                }
           }
        }
}
