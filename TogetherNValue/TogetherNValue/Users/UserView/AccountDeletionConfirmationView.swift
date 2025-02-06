
import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct AccountDeletionConfirmationView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var body: some View {
        ZStack{
            
            Color.skyblue
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20){
                VStack{
                    Text("같이N가치를")
                        .font(.title)
                        .bold()
                        .padding(.trailing, 100)
                    
                    Text("정말 탈퇴하시겠습니까?")
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // 앱 사진 슬라이드 쇼
                FeatureSlideshowView()
                    .padding(.bottom, 50)
                
                Text("탈퇴 후에는\n모든 데이터가 삭제되며 복구할 수 없습니다.")
                    .font(.body)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                
                if isProcessing{
                    ProgressView()
                        .padding()
                } else {
                    Button(action: {
                        deleteAccount()
                    }){
                        Text("탈퇴하기")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.white)
                            .frame(width: 280, height: 40)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .padding()
            .alert(isPresented: $showAlert){
                Alert(
                    title: Text("알림"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    func deleteAccount() {
        guard let userId = userManager.userId else {
            alertMessage = "로그인된 사용자 정보가 없습니다."
            showAlert = true
            return
        }
        
        isProcessing = true
        
        // Step 1: URL 먼저 가져오기
        db.collection("users").document(userId).getDocument { document, error in
            guard let document = document, let profileImageUrl = document.data()?["profile_image_url"] as? String else {
                self.alertMessage = "프로필 이미지 URL을 가져오는 데 실패했습니다."
                self.showAlert = true
                self.isProcessing = false
                return
            }
            
            // Step 2: 프로필 이미지 삭제
            self.deleteProfileImage(profileImageUrl)
            
            // Step 3: 사용자 데이터 업데이트
            self.updateUserDocument(userId: userId)
            
            // Step 4: 게시물 상태 및 관련 이미지 삭제
            self.updatePostsAndImages(for: userId) {
                // Step 5: 댓글 및 대댓글 내용 업데이트
                self.updateCommentsAndReplies(for: userId) {
                    // Step 6: 최종 처리 완료
                    self.completeAccountDeletion()
                }
            }
        }
    }

    
    // 프로필 이미지 삭제
    private func deleteProfileImage(_ profileImageUrl: String) {
        guard let path = extractStoragePath(from: profileImageUrl) else {
            print("프로필 이미지 경로를 추출할 수 없습니다.")
            return
        }
        
        let storageRef = storage.reference().child(path)
        storageRef.delete { error in
            if let error = error {
                print("프로필 이미지 삭제 실패: \(error.localizedDescription)")
            } else {
                print("프로필 이미지 삭제 성공")
            }
        }
    }
    
    private func extractStoragePath(from url: String) -> String? {
        guard let range = url.range(of: "/o/") else { return nil }
        let encodedPath = url[range.upperBound...]
            .components(separatedBy: "?")
            .first ?? "" // 경로에서 쿼리 파라미터 제거
        return encodedPath.removingPercentEncoding // URL 디코딩
    }

    // 사용자 데이터 업데이트
    private func updateUserDocument(userId: String) {
        let currentDate = Date()
        let currentTimestamp = Timestamp(date: currentDate)
        
        db.collection("users").document(userId).updateData([
            "name": "탈퇴한 회원",
            "profile_image_url": FieldValue.delete(),
            "isActive": "N",
            "deleted_at" : currentTimestamp
        ]) { error in
            if let error = error {
                print("사용자 데이터 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("사용자 데이터 업데이트 성공")
            }
            isProcessing = false
        }
    }
    
    private func updatePostsAndImages(for userId: String, completion: @escaping () -> Void) {
        db.collection("posts")
            .whereField("user_idx", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("게시물 업데이트 중 오류 발생: \(error.localizedDescription)")
                    completion()
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                
                snapshot?.documents.forEach { document in
                    let postIdx = document.documentID
                    dispatchGroup.enter()
                    
                    // 게시물 상태 업데이트
                    db.collection("posts").document(postIdx).updateData([
                        "post_status": "거래 불가능"
                    ]) { error in
                        if let error = error {
                            print("게시물 상태 업데이트 실패: \(error.localizedDescription)")
                        }
                        
                        // 게시물 이미지 삭제
                        self.deletePostImages(for: postIdx) {
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion()
                }
            }
    }

    // 게시물 이미지 삭제
    private func deletePostImages(for postIdx: String, completion: @escaping () -> Void) {
        db.collection("posts").document(postIdx).collection("postImages")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("postImages 하위 컬렉션 로드 실패: \(error.localizedDescription)")
                    completion()
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                
                snapshot?.documents.forEach { document in
                    let documentId = document.documentID
                    if let imageUrl = document.data()["image_url"] as? String,
                       let path = self.extractStoragePath(from: imageUrl) {
                        
                        let storageRef = self.storage.reference().child(path)
                        
                        // 스토리지 이미지 삭제
                        dispatchGroup.enter()
                        storageRef.delete { error in
                            if let error = error {
                                print("이미지 삭제 실패: \(error.localizedDescription)")
                            } else {
                                print("이미지 삭제 성공: \(path)")
                            }
                            dispatchGroup.leave()
                        }
                    }

                    // Firestore에서 하위 컬렉션 문서 삭제
                    dispatchGroup.enter()
                    db.collection("posts").document(postIdx).collection("postImages").document(documentId)
                        .delete { error in
                            if let error = error {
                                print("하위 컬렉션 문서 삭제 실패: \(error.localizedDescription)")
                            } else {
                                print("하위 컬렉션 문서 삭제 성공: \(documentId)")
                            }
                            dispatchGroup.leave()
                        }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion()
                }
            }
    }
    
    private func updateCommentsAndReplies(for userId: String, completion: @escaping () -> Void) {
        db.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("posts 로드 오류: \(error.localizedDescription)")
                completion()
                return
            }

            guard let posts = snapshot?.documents else {
                print("posts 문서를 찾을 수 없습니다.")
                completion()
                return
            }

            let dispatchGroup = DispatchGroup()

            for post in posts {
                let postIdx = post.documentID
                
                // 댓글 업데이트
                dispatchGroup.enter()
                db.collection("posts").document(postIdx).collection("comments")
                    .whereField("user_idx", isEqualTo: userId)
                    .getDocuments { commentsSnapshot, error in
                        if let error = error {
                            print("댓글 로드 오류: \(error.localizedDescription)")
                            dispatchGroup.leave()
                            return
                        }

                        commentsSnapshot?.documents.forEach { comment in
                            let commentIdx = comment.documentID
                            
                            // 댓글 내용 업데이트
                            db.collection("posts").document(postIdx).collection("comments").document(commentIdx)
                                .updateData([
                                    "comment_content": "탈퇴한 회원으로 내용 볼 수 없음"
                                ]) { error in
                                    if let error = error {
                                        print("댓글 업데이트 오류: \(error.localizedDescription)")
                                    }
                                }

                            // 대댓글 업데이트
                            dispatchGroup.enter()
                            db.collection("posts").document(postIdx).collection("comments").document(commentIdx).collection("replies")
                                .whereField("user_idx", isEqualTo: userId)
                                .getDocuments { repliesSnapshot, error in
                                    if let error = error {
                                        print("대댓글 로드 오류: \(error.localizedDescription)")
                                        dispatchGroup.leave()
                                        return
                                    }

                                    repliesSnapshot?.documents.forEach { reply in
                                        db.collection("posts").document(postIdx).collection("comments").document(commentIdx).collection("replies").document(reply.documentID)
                                            .updateData([
                                                "reply_content": "탈퇴한 회원으로 내용 볼 수 없음"
                                            ]) { error in
                                                if let error = error {
                                                    print("대댓글 업데이트 오류: \(error.localizedDescription)")
                                                }
                                            }
                                    }

                                    dispatchGroup.leave()
                                }
                        }
                        
                        dispatchGroup.leave()
                    }
            }

            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    }

    // 계정 삭제 완료 처리
   private func completeAccountDeletion() {
       self.isProcessing = false
       self.alertMessage = "회원 탈퇴가 완료되었습니다."
       self.showAlert = true
       self.userManager.userId = nil
   }
    
}

struct FeatureSlideshowView: View {
    @State private var currentIndex = 0
    private let images = ["Mainlogo","Image1", "Image2"]
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(width: .infinity, height: 350)
        .onAppear {
            startAutoSlide()
        }
    }
    
    private func startAutoSlide() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            currentIndex = (currentIndex + 1) % images.count
        }
    }
}


#Preview {
    AccountDeletionConfirmationView()
}
