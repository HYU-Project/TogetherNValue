//
//  DetailPostFirestoreService.swift
//  hkkim_front
//
//  Created by 김소민 on 12/30/24.
//

import FirebaseFirestore

class DetailPostFirestoreService {
    private let db = Firestore.firestore()
    
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
}
