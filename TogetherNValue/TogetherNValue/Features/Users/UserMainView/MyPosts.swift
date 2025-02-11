// MyPosts : MyHomeMain에서 유저가 작성한 게시물 목록 리스트

import SwiftUI

struct MyPosts: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedPostStatus: String = "거래가능"
    @State private var showingOptions = false // 옵션(거래완료, 게시글 삭제, 닫기)
    @State private var selectedPost: MyPost? = nil // 선택된 게시글을 저장할 변수
    
    @State private var posts: [MyPost] = []
    
    private let firestoreService = MyPostFirestoreService()
    
    func loadPosts(){
        guard let userId = userManager.userId else {
            print("userID is nil")
            return
        }
        
        firestoreService.loadPosts(user_idx: userId, post_status: selectedPostStatus){
            loadedPosts in
            self.posts = loadedPosts
        }
    }
    
    // 선택한 상태에 따라 필터링된 게시물
    var filteredPosts: [MyPost] {
        posts.filter { post in
            (selectedPostStatus.isEmpty || post.post_status == selectedPostStatus)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("내가 작성한 게시물")
                    .font(.title)
                    .bold()
                    .padding()
                    .padding(.bottom, 20)
                
                Divider()
                    .padding(.bottom, 10)
                
                // 거래 상태 필터
                PostFilterView(selectedPostStatus: $selectedPostStatus, loadPosts: loadPosts)
                
                // 게시물 목록
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(filteredPosts) { post in
                            PostItemView(post: post) { post in
                                selectedPost = post
                                showingOptions = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .confirmationDialog("옵션 선택", isPresented: $showingOptions, titleVisibility: .visible) {
                OptionsDialogView(
                    selectedPost: selectedPost,
                    showingOptions: $showingOptions,
                    updatePostStatus: updatePostStatus,
                    deletePost: deletePost
                )
            }
            .onAppear {
                // 화면이 나타날 때 거래가능 상태 게시물 로드
                if userManager.userId != nil {
                    loadPosts()
                }
            }
            .onChange(of: userManager.userId) { newUserId in
                if let newUserId = newUserId {
                    print("User ID changed: \(newUserId)")
                    loadPosts()
                }
            }
            .onChange(of: selectedPostStatus) { newStatus in
                print("Selected status changed to: \(newStatus)")
                loadPosts() // 상태 변경 시 게시물 다시 로드
            }
        }
    }
        
    // 거래 완료로 상태 변화
    private func updatePostStatus(post: MyPost) {
        let postIdx = post.post_idx

        // Firestore에서 post_status 업데이트
        firestoreService.updatePostStatus(postIdx: postIdx, newStatus: "거래완료") { success in
            if success {
                // 로컬 상태도 업데이트
                if let index = posts.firstIndex(where: { $0.post_idx == postIdx }) {
                    posts[index].post_status = "거래완료"
                }
            } else {
                print("Failed to update post status in Firestore.")
            }
        }
    }
    
    private func deletePost(post: MyPost) {
        // Firestore에서 게시글 삭제 호출
        firestoreService.deletePost(postIdx: post.post_idx) { success in
            if success {
                // 삭제 성공 시 로컬 상태 업데이트
                posts.removeAll { $0.post_idx == post.post_idx }
                print("게시글 삭제 완료: \(post.post_idx)")
            } else {
                // 삭제 실패 시 알림 또는 에러 처리
                print("게시글 삭제 실패: \(post.post_idx)")
            }
        }
    }

}

#Preview {
    MyPosts()
        .environmentObject(UserManager())
}
