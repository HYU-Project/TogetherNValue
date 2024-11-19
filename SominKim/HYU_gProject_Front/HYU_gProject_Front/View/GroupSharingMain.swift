
//  GroupSharingMain : 나눔 메인 화면

import SwiftUI

struct GroupSharingMain: View {
    var schoolName: String = "한양대학교 서울캠" // 임시로 학교 이름 설정
    @State private var selectedCategory: String = "" // 선택된 카테고리
    @State private var searchText: String = "" // 검색어
    
    @State private var showCreatePostView = false
    
    @State private var posts: [Post] = [
            Post(post_idx: 4, user_idx: 1, post_category: "나눔", post_categoryType: "배달", title: "Title 1", post_content: "내용 1", location: "ITBT관", want_num: 5, post_status: "거래중", created_at: "", postImages: [], post_likeCnt: 10, post_commentCnt: 2),
            Post(post_idx: 5, user_idx: 2, post_category: "나눔", post_categoryType: "식재료", title: "Title 2", post_content: "내용 2", location: "학생회관", want_num: 3, post_status: "거래중", created_at: "", postImages: [], post_likeCnt: 5, post_commentCnt: 1),
            Post(post_idx: 6, user_idx: 3, post_category: "나눔", post_categoryType: "물품", title: "Title 3", post_content: "내용 3", location: "기숙사", want_num: 2, post_status: "거래완료", created_at: "", postImages: [], post_likeCnt: 3, post_commentCnt: 0)
        ]
    
    // 필터링된 게시물 리스트
    var filteredPosts: [Post] {
        posts.filter { post in
            // 선택된 카테고리와 검색어 조건 적용
            (selectedCategory.isEmpty || post.post_categoryType == selectedCategory) &&
            (searchText.isEmpty || post.title.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("나눔")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                }
                .padding()
                
                HStack {
                    Text("   \(schoolName)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Text("여기에 광고 배너 들어가기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                HStack(spacing: 30) {
                    ForEach(["식재료", "물품", "배달"], id: \.self) { category in
                        Button(action: {
                            selectedCategory = selectedCategory == category ? "" : category
                        }) {
                            Text(category)
                                .frame(width: 80, height: 50)
                                .foregroundColor(selectedCategory == category ? .white : .black)
                                .background(selectedCategory == category ? Color.black : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding()
                
                HStack {
                    TextField("Title Search", text: $searchText)
                        .padding(.horizontal)
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                ZStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(filteredPosts) { post in
                                NavigationLink(destination: DetailPost(post_idx: post.post_idx)) {
                                    HStack {
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
                                            
                                            HStack {
                                                Image(systemName: "mappin.and.ellipse")
                                                Text(post.location)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            HStack {
                                                Image(systemName: "person.fill")
                                                Text("\(post.want_num) / \(post.want_num)")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        VStack {
                                            Spacer()
                                            
                                            HStack {
                                                Image(systemName: "heart")
                                                Text("\(post.post_likeCnt)")
                                                Image(systemName: "message")
                                                Text("\(post.post_commentCnt)")
                                                
                                            }
                                            
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
                    
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Button(action: {
                                showCreatePostView.toggle()
                            }){
                                Image(systemName: "plus.square.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.black)
                                   .padding()
                            }
                            .sheet(isPresented: $showCreatePostView){
                                CreatePostView() // 게시물 작성 창
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    GroupSharingMain()
}
