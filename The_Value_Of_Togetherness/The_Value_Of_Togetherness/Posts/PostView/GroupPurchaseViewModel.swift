import SwiftUI
import FirebaseFirestore

class GroupPurchaseViewModel: ObservableObject {
    @Published var schoolIdx: String? = nil
    @Published var schoolName: String? = nil
    @Published var posts: [PurchasePost] = []
    @Published var isLoading = true

    private let firestoreService = PurchaseFirestoreService()
    private let db = Firestore.firestore()

    func fetchSchoolName(userId: String) {
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let schoolIdx = data?["school_idx"] as? String {
                    self.db.collection("schools").document(schoolIdx).getDocument { schoolDocument, error in
                        if let schoolDocument = schoolDocument, schoolDocument.exists {
                            let schoolData = schoolDocument.data()
                            if let schoolName = schoolData?["schoolName"] as? String {
                                DispatchQueue.main.async {
                                    self.schoolIdx = schoolIdx
                                    self.schoolName = schoolName
                                    self.loadPosts()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func loadPosts() {
        guard let schoolIdx = schoolIdx else { return }
        firestoreService.loadPosts(school_idx: schoolIdx, category: "공구") { posts in
            DispatchQueue.main.async {
                self.posts = posts
                self.isLoading = false
            }
        }
    }
}

