
import FirebaseFirestore
import FirebaseStorage

class DetailPostFirestoreService {
    
    private let db = Firestore.firestore()
    
    private let storage = Storage.storage()
    
    func fetchPostDetails(postIdx: String, completion: @escaping (Result<PostInfo, Error>) -> Void) {
        db.collection("posts").document(postIdx).getDocument { document, error in
            if let error = error {
                print("Error fetching post details: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                print("Post not found for ID: \(postIdx)")
                completion(.failure(NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not found"])))
                return
            }
            
            do {
                let post = try document.data(as: PostInfo.self)
                print("Successfully fetched post details: \(String(describing: post))")
                completion(.success(post))
            } catch {
                print("Unexpected decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    func fetchPostImages(postIdx: String, completion: @escaping (Result<[PostImages], Error>) -> Void) {
        db.collection("posts").document(postIdx).collection("postImages").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching post images: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No images found for postIdx: \(postIdx)")
                completion(.success([])) // 빈 배열 반환
                return
            }
            
            let images = documents.compactMap { try? $0.data(as: PostImages.self) }
            print("Fetched \(images.count) images: \(images)")
            completion(.success(images))
        }
    }

    func fetchUserDetails(userIdx: String, completion: @escaping (Result<UserProperty, Error>) -> Void) {
        db.collection("users").document(userIdx).getDocument { document, error in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                print("User not found for ID: \(userIdx)")
                completion(.failure(NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            do {
                let user = try document.data(as: UserProperty.self)
                print("Successfully fetched user details: \(String(describing: user))")
                completion(.success(user))
            } catch {
                print("Unexpected decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
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
    
    // 현재 로그인 한 유저가 게시물을 찜했는지 확인
    func isPostLiked(postIdx: String, userIdx: String, completion: @escaping (Bool) -> Void) {
            let collection = db.collection("postLikes")
            
            collection
                .whereField("post_idx", isEqualTo: postIdx)
                .whereField("user_idx", isEqualTo: userIdx)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error checking post like status: \(error)")
                        completion(false)
                        return
                    }
                    
                    completion(!(snapshot?.documents.isEmpty ?? true))
                }
        }
    
    func updatePostStatus (postIdx: String, newStatus: String, completion: @escaping (Result<Void, Error>) -> Void){
        
        db.collection("posts").document(postIdx).updateData(["post_status" : newStatus]){ error in
            if let error = error {
                print("Error updating post status: \(error.localizedDescription)")
                completion(.failure(error))
            }
            else {
                print("Post status updated to \(newStatus)")
                completion(.success(()))
            }
        }
    }
    
    // 댓글 리스트 가져오기 (대댓글 포함)
    func fetchComments(postIdx: String, completion: @escaping (Result<[Comments], Error>) -> Void) {
        let commentsRef = db.collection("posts").document(postIdx).collection("comments")
        
        commentsRef.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            var comments: [Comments] = []
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                let data = document.data()
                let commentIdx = document.documentID
                let userIdx = data["user_idx"] as? String ?? ""
                let content = data["comment_content"] as? String ?? ""
                let createdAt = (data["comment_created_at"] as? Timestamp)?.dateValue() ?? Date()
                
                var comment = Comments(
                    comment_idx: commentIdx,
                    user_idx: userIdx,
                    post_idx: postIdx,
                    comment_content: content,
                    comment_created_at: createdAt,
                    replies: []
                )
                
                // 댓글 작성자 정보 조회
                dispatchGroup.enter()
                self.fetchUserDetails(userIdx: userIdx) { userResult in
                    switch userResult {
                    case .success(let user):
                        comment.user_name = user.name
                        comment.profile_image_url = user.profile_image_url
                    case .failure(let error):
                        print("Error fetching user details for comment: \(error)")
                    }
                    dispatchGroup.leave()
                }
                
                // 대댓글 가져오기
                dispatchGroup.enter()
                self.db.collection("posts")
                    .document(postIdx)
                    .collection("comments")
                    .document(commentIdx)
                    .collection("replies")
                    .getDocuments { replySnapshot, replyError in
                        if let replyDocuments = replySnapshot?.documents {
                            var fetchedReplies: [Replies] = []
                            let replyDispatchGroup = DispatchGroup()
                            
                            for replyDoc in replyDocuments {
                                replyDispatchGroup.enter()
                                let replyData = replyDoc.data()
                                let replyUserIdx = replyData["user_idx"] as? String ?? ""
                                let replyContent = replyData["reply_content"] as? String ?? ""
                                let replyCreatedAt = (replyData["reply_created_at"] as? Timestamp)?.dateValue() ?? Date()
                                
                                var reply = Replies(
                                    reply_idx: replyDoc.documentID,
                                    user_idx: replyUserIdx,
                                    comment_idx: commentIdx,
                                    reply_content: replyContent,
                                    reply_created_at: replyCreatedAt
                                )
                                
                                // 대댓글 작성자 정보 조회
                                self.fetchUserDetails(userIdx: replyUserIdx) { userResult in
                                    switch userResult {
                                    case .success(let replyUser):
                                        reply.user_name = replyUser.name
                                        reply.profile_image_url = replyUser.profile_image_url
                                    case .failure(let error):
                                        print("Error fetching user details for reply: \(error)")
                                    }
                                    fetchedReplies.append(reply)
                                    replyDispatchGroup.leave()
                                }
                            }
                            
                            replyDispatchGroup.notify(queue: .main) {
                                comment.replies = fetchedReplies
                                dispatchGroup.leave()
                            }
                        } else {
                            print("Replies fetch error for \(commentIdx): \(replyError?.localizedDescription ?? "Unknown error")")
                            dispatchGroup.leave()
                        }
                    }
                
                // 모든 비동기 작업이 끝난 뒤에 comments에 추가
                dispatchGroup.notify(queue: .main) {
                    comments.append(comment)
                }
            }
            
            // 모든 댓글과 대댓글의 비동기 작업이 끝난 뒤 completion 호출
            dispatchGroup.notify(queue: .main) {
                print("Fetched comments and replies for post: \(postIdx)")
                completion(.success(comments))
            }
        }
    }


    // 댓글 추가
    func addComment(postIdx: String, userIdx: String, content: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let commentData: [String: Any] = [
            "user_idx": userIdx,
            "comment_content": content,
            "comment_created_at": FieldValue.serverTimestamp()
        ]
        
        db.collection("posts").document(postIdx).collection("comments").addDocument(data: commentData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // 대댓글 추가
    func addReply(commentIdx: String, postIdx: String, userIdx: String, content: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let replyData: [String: Any] = [
            "user_idx": userIdx,
            "reply_content": content,
            "reply_created_at": FieldValue.serverTimestamp()
        ]
        
        db.collection("posts")
            .document(postIdx)
            .collection("comments")
            .document(commentIdx)
            .collection("replies")
            .addDocument(data: replyData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // 댓글, 대댓글 수정
    func updateDocument(path: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void){
        Firestore.firestore().document(path).updateData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // 댓글 삭제
    func deleteCollection(path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let collectionRef = Firestore.firestore().collection(path)
        
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success(()))
                return
            }
            
            let batch = Firestore.firestore().batch()
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { batchError in
                if let batchError = batchError {
                    completion(.failure(batchError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    
    // 대댓글 삭제
    func deleteDocument(path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().document(path).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
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
