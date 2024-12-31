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
}
