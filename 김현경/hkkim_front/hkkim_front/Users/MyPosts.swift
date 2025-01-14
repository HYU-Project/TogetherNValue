// MyPosts : MyHomeMain에서 유저가 작성한 게시물 목록 리스트

//TODO: 거래중, 거래완료 post_status에 따라 user가 작성한 게시글 불러오기
//TODO: 거래중을 거래 완료로 변경하고 table 수정
//TODO: 게시글 삭제

import SwiftUI

struct MyPosts: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedPostStatus: String = "거래중"
    @State private var showingOptions = false // 옵션(거래 완료, 게시글 삭제, 닫기)
    @State private var selectedPost: MyPost? = nil // 선택된 게시글을 저장할 변수
    
    @State private var posts: [MyPost] = []
    
    private let firestoreService = MyPostFirestoreService()
    
    func loadPosts(){
        guard let userId = userManager.userId else {
            print("userID is nil")
            return
        }
        
        print("Loading posts for user: \(userId)")
        firestoreService.loadPosts(user_idx: userId, post_status: selectedPostStatus){
            loadedPosts in
            self.posts = loadedPosts
        }
    }
    
    var filteredPosts: [MyPost]{
        posts.filter { post in
            (selectedPostStatus.isEmpty || post.post_status == selectedPostStatus)
        }
    }
    
    var body: some View {
        NavigationView{
            VStack{
                
                Text("내가 작성한 게시물")
                    .font(.title)
                    .bold()
                    .padding()
                    .padding(.bottom, 20)
                
                Divider()
                    .padding(.bottom, 10)
                
                PostFilterView(selectedPostStatus: $selectedPostStatus, loadPosts: loadPosts)
                
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
                if userManager.userId != nil {
                    loadPosts()
                }
            }
            .onChange(of: userManager.userId) { newUserId in
                if newUserId != nil {
                    loadPosts()  // 로그인된 후 게시글 불러오기
                }
            }
        }
    }
        
    // 거래 완료로 상태 변화
    private func updatePostStatus(post: MyPost) {
        if let index = posts.firstIndex(where: { $0.post_idx == post.post_idx }) {
            posts[index].post_status = "거래완료"
        }
    }
    
    // 게시글 삭제
    private func deletePost(post: MyPost) {
        posts.removeAll { $0.post_idx == post.post_idx }
    }
}

#Preview {
    MyPosts()
        .environmentObject(UserManager())
}
