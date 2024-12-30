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
                completion(.failure(error))
                return
            }
            guard let document = document, document.exists, let post = try? document.data(as: PostInfo.self) else {
                completion(.failure(NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not found"])))
                return
            }
            completion(.success(post))
        }
    }

    func fetchPostImages(postIdx: String, completion: @escaping (Result<[PostImages], Error>) -> Void) {
        db.collection("posts").document(postIdx).collection("postImages").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let images = snapshot?.documents.compactMap { try? $0.data(as: PostImages.self) } ?? []
            completion(.success(images))
        }
    }

    func fetchUserDetails(userIdx: String, completion: @escaping (Result<UserProperty, Error>) -> Void) {
        db.collection("users").document(userIdx).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let document = document, document.exists, let user = try? document.data(as: UserProperty.self) else {
                completion(.failure(NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            completion(.success(user))
        }
    }
}
