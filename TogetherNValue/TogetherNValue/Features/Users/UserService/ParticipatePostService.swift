
import FirebaseStorage
import FirebaseFirestore

class ParticipatePostService {

    let db = Firestore.firestore()

    func fetchParticipatePost(for userId: String, completion: @escaping (Result<[ParticiaptePost], Error>) -> Void) {
        db.collection("chattingRooms")
            .whereField("guest_idx", isEqualTo: userId)
            .whereField("roomState", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching chattingRooms: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No chattingRooms found for userId: \(userId)")
                    completion(.success([]))
                    return
                }

                // roomState와 post_idx 추출
                let roomData = documents.compactMap { doc -> (String, Bool)? in
                    guard
                        let postIdx = doc.data()["post_idx"] as? String,
                        let roomState = doc.data()["roomState"] as? Bool
                    else {
                        return nil
                    }
                    return (postIdx, roomState)
                }

                let postIds = roomData.map { $0.0 }
                let roomStates = Dictionary(uniqueKeysWithValues: roomData)

                guard !postIds.isEmpty else {
                    print("No postIds found for userId: \(userId)")
                    completion(.success([]))
                    return
                }

                // posts 컬렉션에서 post_idx와 일치하는 데이터 가져오기
                self.fetchPosts(by: postIds, roomStates: roomStates, completion: completion)
            }
    }

    private func fetchPosts(by postIds: [String], roomStates: [String: Bool], completion: @escaping (Result<[ParticiaptePost], Error>) -> Void) {
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

                var posts: [ParticiaptePost] = []

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

                    let roomState = roomStates[postIdx] ?? true // 기본값 true(참여중)

                    // 첫 번째 이미지 로드
                    self.loadPostImage(postIdx: postIdx) { imageUrl in
                        let post = ParticiaptePost(
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
                            roomState: roomState
                        )

                        posts.append(post)

                        if posts.count == documents.count {
                            completion(.success(posts))
                        }
                    }
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
}
