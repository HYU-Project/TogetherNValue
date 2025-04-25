
import SwiftUI

struct InterestedPosts: View {
    @EnvironmentObject var userManager: UserManager
    
    @State private var posts: [InterestedPost] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let interestedPostService = InterestedPostService()
    
    private func fetchData() {
        guard let userId = userManager.userId else {
            print("User ID is nil")
            return
        }
        
        isLoading = true
        interestedPostService.fetchInterestedPosts(for: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedPosts):
                    print("Fetched posts: \(fetchedPosts)")
                    self.posts = fetchedPosts
                    
                    // 각 게시물의 찜 개수를 가져오기
                    for index in self.posts.indices {
                        self.fetchPostLikeCount(for: self.posts[index].post_idx) { likeCount in
                            DispatchQueue.main.async {
                                self.posts[index].post_likeCnt = likeCount
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }

    private func fetchPostLikeCount(for postIdx: String, completion: @escaping (Int) -> Void) {
        interestedPostService.fetchPostLikeCount(for: postIdx) { result in
            switch result {
            case .success(let likeCount):
                print("Post ID: \(postIdx), 찜한 수: \(likeCount)")
                completion(likeCount)
            case .failure(let error):
                print("Post ID: \(postIdx), 찜 개수를 가져오는 중 오류 발생: \(error.localizedDescription)")
                completion(0) 
            }
        }
    }

    
    private func toggleLike(for post: InterestedPost) {
        guard let userId = userManager.userId else { return }

        // 현재 찜 상태를 반대로 설정
        let isCurrentlyLiked = posts.contains { $0.post_idx == post.post_idx }
        
        interestedPostService.togglePostLike(postIdx: post.post_idx, userIdx: userId, isLiked: isCurrentlyLiked) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // 찜 상태를 반대로 업데이트
                    if isCurrentlyLiked {
                        posts.removeAll { $0.post_idx == post.post_idx } // 찜 취소
                    } else {
                        fetchData() // 찜 추가 후 목록 새로고침
                    }
                case .failure(let error):
                    errorMessage = "Error toggling like: \(error.localizedDescription)"
                }
            }
        }
    }
    
    var body: some View {
        NavigationView{
            VStack{
                Text("관심 목록")
                    .font(.title)
                    .bold()
                    .padding()
                    .padding(.bottom, 20)
                
                Divider()
                    .padding(.bottom, 10)
                
                if isLoading {
                    
                    Spacer()
                    
                    ProgressView("Loading...")
                        .padding()
                    
                    Spacer()
                }
                else if posts.isEmpty {
                    Text("찜한 게시물이 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Spacer()
                }
                else {
                    ScrollView {
                        VStack(spacing: 5){
                            ForEach(posts){ post in
                                NavigationLink(destination: DetailPost(post_idx: post.post_idx)) {
                                    
                                    InterestedPostRow(
                                        post: post,
                                        toggleLikeAction: toggleLike
                                    )
                                    .padding(5)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
                
            }
            .onAppear {
                fetchData()
            }
        }
    }
}

#Preview {
    InterestedPosts()
        .environmentObject(UserManager())
}
