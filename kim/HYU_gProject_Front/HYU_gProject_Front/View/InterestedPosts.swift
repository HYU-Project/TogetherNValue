
//  InterestedPosts : MyHomeMain에서 유저가 찜한 게시물들 리스트

import SwiftUI

struct InterestedPosts: View {
    @State private var likedPosts: Set<Int> = [1,4]  // 좋아요 상태를 추적
    
    @State private var posts: [Post] = [
        Post(post_idx: 1, user_idx: 2, post_category: "공구", post_categoryType: "배달", title: "Title 1", post_content: "내용 1", location: "ITBT관", want_num: 5, post_status: "거래중", created_at: "", postImages: [], post_likeCnt: 10, post_commentCnt: 2),
        Post(post_idx: postd4.postID, user_idx: postd4.userID, post_category: postd4.postCategory, post_categoryType: postd4.postCategoryType, title: postd4.title, post_content: postd4.postContent, location: postd4.location, want_num: postd4.wantNum, post_status: postd4.postStatus, created_at: postd4.created_at, postImages: [], post_likeCnt: 7, post_commentCnt: 7)
    ]
    
    var body: some View {
        NavigationView{
                VStack(alignment: .leading) {
                HStack {
                    Text("관심 목록")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack {
                        ForEach(posts) { post in
                            NavigationLink(destination: DetailPost(post_idx: post.post_idx)) {
                                HStack(spacing: 20) {
                                    if let firstImage = post.postImages.first {
                                        AsyncImage(url: URL(string: firstImage.image_url)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 50, height: 50)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .cornerRadius(8)
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.gray)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 70, height: 70)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                
                                VStack {
                                    Text(post.title)
                                        .font(.title2)
                                        .bold()
                                        .padding()
                                    
                                    if post.post_status == "거래중" {
                                        Text(post.post_status)
                                            .font(.title3)
                                            .foregroundColor(.red)
                                            .bold()
                                            .padding()
                                        
                                    }
                                    else {
                                        Text(post.post_status)
                                            .font(.title3)
                                            .foregroundColor(.green)
                                            .bold()
                                            .padding()
                                    }
                                }
                                
                                Spacer()
                                
                                VStack {
                                    // 좋아요 상태에 따라 하트 아이콘을 변경
                                    Button(action: {
                                        toggleLike(for: post)
                                    }) {
                                        Image(systemName: likedPosts.contains(post.post_idx) ? "heart.fill" : "heart")
                                            .foregroundColor(.black)
                                            .font(.title)
                                    }
                                }
                                .padding()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
        
        // 좋아요 상태 토글 함수
    private func toggleLike(for post: Post) {
        if likedPosts.contains(post.post_idx) {
                likedPosts.remove(post.post_idx)  // 좋아요 취소
            
            // 게시글 목록에서 해당 포스트 제거 (UI에서 즉시 반영)
            posts.removeAll { $0.post_idx == post.post_idx }
            
            // 서버에서 좋아요 삭제 처리
            
            }
    }
        
    }

#Preview {
    InterestedPosts()
}
