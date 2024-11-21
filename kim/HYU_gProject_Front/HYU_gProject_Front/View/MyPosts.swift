// MyPosts : MyHomeMain에서 유저가 작성한 게시물 목록 리스트

import SwiftUI

struct MyPosts: View {
    
    @State private var selectedPostStatus: String = ""
    @State private var showingOptions = false // 옵션(게시글 수정, 거래 완료, 게시글 삭제, 닫기)
    @State private var selectedPost: Post? = nil // 선택된 게시글을 저장할 변수
    
    @State private var posts: [Post] = [
        Post(post_idx: 1, user_idx: 1, post_category: "공구", post_categoryType: "배달", title: "Title 1", post_content: "내용 1", location: "ITBT관", want_num: 5, post_status: "거래중", created_at: "", postImages: [], post_likeCnt: 10, post_commentCnt: 2),
        Post(post_idx: 3, user_idx: 1, post_category: "공구", post_categoryType: "물품", title: "Title 3", post_content: "내용 3", location: "기숙사", want_num: 2, post_status: "거래완료", created_at: "", postImages: [], post_likeCnt: 3, post_commentCnt: 0),
        Post(post_idx: 5, user_idx: 1, post_category: "나눔", post_categoryType: "식재료", title: "Title 2", post_content: "내용 2", location: "학생회관", want_num: 3, post_status: "거래중", created_at: "", postImages: [], post_likeCnt: 5, post_commentCnt: 1),
        Post(post_idx: 6, user_idx: 1, post_category: "나눔", post_categoryType: "물품", title: "Title 3", post_content: "내용 3", location: "기숙사", want_num: 2, post_status: "거래완료", created_at: "", postImages: [], post_likeCnt: 3, post_commentCnt: 0)
    ]
    
    var filteredPosts: [Post]{
        posts.filter { post in
            (selectedPostStatus.isEmpty || post.post_status == selectedPostStatus)
        }
    }
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                
                HStack{
                    Text("내가 작성한 게시글")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                }
                
                // 내가 작성한 게시글 중 거래 진행중인 게시글 / 거래 완료 게시글 버튼 클릭 시 리스트 출력해야함
                HStack(spacing: 30){
                    ForEach(["거래중", "거래완료"], id: \.self){
                        status in
                        Button(action: {
                            selectedPostStatus = selectedPostStatus == status ? "" : status
                        }){
                            Text(status)
                                .frame(width: 100, height: 50)
                                .foregroundColor(selectedPostStatus == status ? .white : .black)
                                .background(selectedPostStatus == status ? Color.black : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(.leading, 80)
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 10){
                        ForEach(filteredPosts){
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
                                            .foregroundColor(post.post_status == "거래중" ? .red : .green)
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
            .confirmationDialog("옵션 선택", isPresented: $showingOptions, titleVisibility: .visible) {
                // 게시글 수정
                if let selectedPost = selectedPost {
                    Button("게시글 수정") {
                        // 게시글 수정 로직
                        print("게시글 수정: \(selectedPost.title)")
                        showingOptions = false
                    }
                }
                
                // 거래 중인 것만 거래 완료
                if let selectedPost = selectedPost, selectedPost.post_status == "거래중" {
                    Button("거래 완료") {
                        // 거래 완료 로직
                        updatePostStatus(post: selectedPost)
                        showingOptions = false
                    }
                }
                
                // 게시글 삭제
                if let selectedPost = selectedPost {
                    Button("게시글 삭제") {
                        // 게시글 삭제 로직
                        deletePost(post: selectedPost)
                        showingOptions = false
                    }
                }
                
                // 닫기
                Button("닫기", role: .cancel) {
                    showingOptions = false
                }
            }
        }
    }
        
        // 거래 완료 상태로 변경하는 함수
        private func updatePostStatus(post: Post) {
            if let index = posts.firstIndex(where: { $0.post_idx == post.post_idx }) {
                posts[index].post_status = "거래완료"
            }
        }
        
        // 게시글 삭제 함수
        private func deletePost(post: Post) {
            posts.removeAll { $0.post_idx == post.post_idx }
        }
}


#Preview {
    MyPosts()
}

