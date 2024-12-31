//  DetailPost : 공구/나눔 게시글 디테일

import SwiftUI

struct DetailPost: View {
    @EnvironmentObject var userManager: UserManager
    var post_idx: String // 전달받은 post_idx
    
    @State private var postDetails: PostInfo?
    @State private var postImages: [PostImages] = []
    @State private var postUser: UserProperty?
    @State private var currentImageIndex = 0
    @State private var isLoading = true
    
    private let firestoreService = DetailPostFirestoreService()
    
    private func fetchData() {
            firestoreService.fetchPostDetails(postIdx: post_idx) { result in
                switch result {
                case .success(let post):
                    DispatchQueue.main.async {
                        self.postDetails = post
                    }
                    if let postId = post.id { // post.id 사용
                        fetchImages(for: postId)
                    } else {
                        print("Error: Post ID is nil.")
                    }
                    fetchUserDetails(for: post.user_idx)
                case .failure(let error):
                    print("Error fetching post details: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }
        
        private func fetchImages(for postIdx: String) {
            firestoreService.fetchPostImages(postIdx: postIdx) { result in
                switch result {
                case .success(let images):
                    DispatchQueue.main.async {
                        self.postImages = images
                    }
                case .failure(let error):
                    print("Error fetching images: \(error)")
                }
            }
        }
        
        private func fetchUserDetails(for userIdx: String) {
            firestoreService.fetchUserDetails(userIdx: userIdx) { result in
                switch result {
                case .success(let user):
                    DispatchQueue.main.async {
                        self.postUser = user
                    }
                case .failure(let error):
                    print("Error fetching user details: \(error)")
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    
    var body: some View {
        if isLoading {
            ProgressView("Loading....")
                .onAppear{
                    fetchData()
                }
        }
        else{
            VStack{
                ScrollView{
                    VStack(alignment: .leading) {
                        // 작성자 정보 (프로필 사진 및 아이디)
                        HStack {
                            if let postUser = postUser,
                               let profileURL = postUser.profile_image_url, // 옵셔널 바인딩
                               let url = URL(string: profileURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                    case .failure:
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    @unknown default:
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                    }
                                }
                            } else {
                                // 기본 이미지 처리
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            }

                            
                            Text(postUser?.name ?? "익명") // 작성자 이름
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        
                        // 게시글 제목
                        if let postDetails = postDetails {
                            Text(postDetails.title)
                                .font(.title2)
                                .bold()
                                .padding()
                                .frame(width: 200)
                                .frame(height: 25)
                                .padding(.trailing, 200)
                                .padding(.bottom, 5)
                        }
                        else {
                            Text("게시글 정보를 불러오는 중...")
                                .italic()
                                .padding(.bottom, 5)
                        }
                        
                        // 이미지 슬라이더
                        // (수정 필요)이미지가 없으면 기본 이미지가 아닌 다른 정보만 제공하도록
                        if !postImages.isEmpty {
                            TabView(selection: $currentImageIndex) {
                                ForEach(postImages.indices, id: \.self) { index in
                                    let imageURLString = postImages[index].image_url // `postImages` 모델의 `image_url`
                                    if let imageURL = URL(string: imageURLString) {
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(height: 200) // 로딩 중 상태
                                            case .success(let image):
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(height: 200)
                                                    .clipped()
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 200)
                                                    .clipped()
                                            @unknown default:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 200)
                                                    .clipped()
                                            }
                                        }
                                    } else {
                                        // URL이 잘못된 경우 기본 이미지 표시
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .clipped()
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(height: 200)
                            .padding()
                        } else {
                            Text("이미지가 없습니다")
                                .italic()
                                .padding()
                        }


                        
                        // 장소와 인원 정보
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("장소: \(postDetails?.location ?? "장소 미정")")
                                }
                                .padding(.top, 8)
                                
                                HStack {
                                    Image(systemName: "person.2.fill")
                                    Text("인원수: \(postDetails?.want_num ?? 0)명")
                                }
                                .padding(.top, 4)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        
                        // 게시글 내용
                        if let postContent = postDetails?.post_content{
                            Text(postContent)
                                .frame(width: 350, height: 200)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .padding()
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                // 채팅하기 버튼 액션
                            }) {
                                Text("채팅하기")
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.trailing, 1)
                    }
                    .padding()
                    
                    Divider()
                    
                    Text("여기에 광고 배너 들어가기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    // 댓글 영역
                    
        }
            }
        }
    }
    
}
        

#Preview {
    DetailPost(post_idx: "sq0M7IBzRVAhiax2UXbj")
        .environmentObject(UserManager())
}
