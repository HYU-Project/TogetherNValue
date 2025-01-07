//
//  InterestedPosts.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

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
        
        print("fetchData called with userId: \(userId)")
        
        isLoading = true
        interestedPostService.fetchInterestedPosts(for: userId){
            result in
            DispatchQueue.main.async{
                isLoading = false
                switch result {
                case .success(let fetchedPosts):
                    print("Fetched posts: \(fetchedPosts)")
                    posts = fetchedPosts
                case .failure(let error):
                    print("Error fetching posts: \(error.localizedDescription)")
                    print("Error fetching interested posts: \(error)")
                }
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
                        VStack{
                            ForEach(posts){ post in
                                NavigationLink(destination: DetailPost(post_idx: post.post_idx)) {
                                    
                                    InterestedPostRow(
                                        post: post,
                                        toggleLikeAction: toggleLike
                                    )
                                                                }
                                .padding()
                                
                            }
                        }
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
