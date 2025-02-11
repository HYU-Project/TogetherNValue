import SwiftUI
import FirebaseFirestore

struct ParticipateTransactionPosts: View {
    @EnvironmentObject var userManager: UserManager
    @State private var participatedPosts: [(postId: String, title: String)] = [] // 참여한 게시물 목록
    @State private var isLoading = true
    private var db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("로딩 중...")
                        .padding()
                } else if participatedPosts.isEmpty {
                    Text("참여한 거래가 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(participatedPosts, id: \.postId) { post in
                        NavigationLink(
                            destination: DetailPost(post_idx: post.postId),
                            label: {
                                Text(post.title)
                                    .font(.headline)
                            }
                        )
                    }
                }
            }
            .navigationTitle("참여한 거래")
        }
        .onAppear {
            fetchParticipatedPosts()
        }
    }

    private func fetchParticipatedPosts() {
        guard let userId = userManager.userId else {
            print("유저 ID 없음")
            self.isLoading = false
            return
        }

        db.collection("chattingRooms")
            .whereField("guest_idx", isEqualTo: userId)
            .whereField("roomState", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("채팅방 로드 오류: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("참여한 거래 데이터 없음")
                    self.isLoading = false
                    return
                }

                // chattingRooms의 post_idx 수집
                let postIds = documents.compactMap { $0.data()["post_idx"] as? String }

                if postIds.isEmpty {
                    print("관련 게시물 없음")
                    self.isLoading = false
                    return
                }

                // post_idx를 사용하여 posts 정보 가져오기
                self.fetchPosts(postIds: postIds)
            }
    }

    private func fetchPosts(postIds: [String]) {
        db.collection("posts")
            .whereField(FieldPath.documentID(), in: postIds)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("게시물 로드 오류: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("게시물 데이터 없음")
                    self.isLoading = false
                    return
                }

                // postId와 제목 저장
                self.participatedPosts = documents.compactMap { document in
                    let data = document.data()
                    if let title = data["title"] as? String {
                        return (postId: document.documentID, title: title)
                    }
                    return nil
                }

                self.isLoading = false
            }
    }
}


#Preview {
    ParticipateTransactionPosts()
        .environmentObject(UserManager())
}
