
//  ParticipateTransactionPosts : MyHomeMain에서 유저가 참여한 거래 정보

import SwiftUI

struct ParticipateTransactionPosts: View {
    
    @State private var selectedPostStatus: String = ""
    @State private var showingOptions = false // 옵션(목록에서 지우기, 닫기)
    @State private var selectedPost: Post? = nil // 선택된 게시글을 저장할 변수
    
    @State private var posts: [Post] = [
        Post(post_idx: 1, user_idx: 1, post_category: "공구", post_categoryType: "배달", title: "Title 1", post_content: "내용 1", location: "ITBT관", want_num: 5, post_status: "거래완료", created_at: "", postImages: [], post_likeCnt: 10, post_commentCnt: 2),
        Post(post_idx: 3, user_idx: 1, post_category: "공구", post_categoryType: "물품", title: "Title 3", post_content: "내용 3", location: "기숙사", want_num: 2, post_status: "거래완료", created_at: "", postImages: [], post_likeCnt: 3, post_commentCnt: 0),
        Post(post_idx: 5, user_idx: 1, post_category: "나눔", post_categoryType: "식재료", title: "Title 2", post_content: "내용 2", location: "학생회관", want_num: 3, post_status: "거래완료", created_at: "", postImages: [], post_likeCnt: 5, post_commentCnt: 1),
        Post(post_idx: 6, user_idx: 1, post_category: "나눔", post_categoryType: "물품", title: "Title 3", post_content: "내용 3", location: "기숙사", want_num: 2, post_status: "거래완료", created_at: "", postImages: [], post_likeCnt: 3, post_commentCnt: 0)
    ]
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                HStack {
                    Text("참여한 거래")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                }
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 10){
                        ForEach(posts){
                            post in
                            NavigationLink(destination: DetailPost(post_idx: post.post_idx)){
                                HStack(spacing : 20){
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
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("[\(post.title)]")
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        Text(post.post_status)
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack{
                                        // 옵션 버튼
                                        Button(action: {
                                            selectedPost = post
                                            showingOptions = true
                                        }) {
                                            Image("appSetting")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30)
                                        }
                                        .padding(.top, 5)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                        }
                    }
                    .padding()
                }
                
            }
            .padding()
            .confirmationDialog("옵션 선택", isPresented: $showingOptions, titleVisibility: .visible){
                Button("목록에서 지우기"){
                // UI에서만 게시글 삭제 (데이터베이스에는 반영되지 않음)
                    if let selectedPost = selectedPost {
                        posts.removeAll { $0.post_idx == selectedPost.post_idx }
                    }
                    showingOptions = false
                }
                
                Button("닫기", role: .cancel){
                    showingOptions = false
                }
            }
        }
    }
}

#Preview {
    ParticipateTransactionPosts()
}
