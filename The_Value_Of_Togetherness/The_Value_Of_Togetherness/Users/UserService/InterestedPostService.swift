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
        
        db.collection("posts")
            .whereField(FieldPath.documentID(), in: postIds)
            .whereField("post_status", in: ["거래가능", "거래완료"])
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

                let dispatchGroup = DispatchGroup()
                var posts: [InterestedPost] = []

                for document in documents {
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
                        continue
                    }

                    dispatchGroup.enter()
                    // 첫 번째 이미지 로드
                    self.loadPostImage(postIdx: postIdx) { imageUrl in
                        let postLikeCnt = data["post_likeCnt"] as? Int ?? 0
                        let postCommentCnt = data["post_commentCnt"] as? Int ?? 0

                        let post = InterestedPost(
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
                            post_likeCnt: postLikeCnt,
                            post_commentCnt: postCommentCnt
                        )

                        posts.append(post)
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    print("Fetched and parsed posts: \(posts)")
                    completion(.success(posts))
                }
            }
    }

    private func loadPostImage(postIdx: String, completion: @escaping (String?) -> Void) {
        db.collection("posts").document(postIdx).collection("postImages")
            .order(by: "order")
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching postImages for postIdx \(postIdx): \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No postImages found for postIdx: \(postIdx)")
                    completion(nil)
                    return
                }

                let imageUrl = document.data()["image_url"] as? String
                print("Fetched image URL for postIdx \(postIdx): \(String(describing: imageUrl))")
                completion(imageUrl)
            }
    }
    
    func fetchPostLikeCount(for postIdx: String, completion: @escaping (Result<Int, Error>) -> Void) {
        print("Fetching like count for postIdx: \(postIdx)")
        db.collection("postLikes")
            .whereField("post_idx", isEqualTo: postIdx) // post_idx에 해당하는 데이터 필터링
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching like count: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                // 문서의 개수를 카운트
                let likeCount = snapshot?.documents.count ?? 0
                print("Like count for postIdx \(postIdx): \(likeCount)")
                completion(.success(likeCount))
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
