//  DetailPost : 공구/나눔 게시글 디테일

import SwiftUI

func getCurrentTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}

struct DetailPost: View {
    @EnvironmentObject var userManager: UserManager
    var post_idx: String // 전달받은 post_idx
    
    @State private var postDetails: PostInfo?
    @State private var postImages: [PostImages] = []
    @State private var postUser: UserProperty?
    @State private var currentImageIndex = 0
    @State private var isLoading = true
    
    @State private var selectedStatus = "거래가능"
    let statusOptions = ["거래가능", "거래완료"]
    
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
                .onAppear {
                    fetchData()
                }
        } else {
            ZStack(alignment: .bottom) {
                ScrollView {
                        VStack(spacing: 16) {
                        // 이미지 슬라이더
                        if !postImages.isEmpty {
                            TabView(selection: $currentImageIndex) {
                                ForEach(postImages.indices, id: \.self) { index in
                                    if let imageURL = URL(string: postImages[index].image_url) {
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(height: 250)
                                                    .clipped()
                                            case .failure:
                                                Image("NoImage")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: .infinity)
                                                    .frame( height: 250)
                                                    .clipped()
                                            @unknown default:
                                                Image("NoImage")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 250)
                                                    .clipped()
                                            }
                                        }
                                    } else {
                                        Image("NoImage")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 250)
                                            .clipped()
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(height: 250)
                        } else {
                            Text("이미지가 없습니다")
                                .italic()
                                .padding()
                        }
                        
                        // 작성자 정보 표시
                        HStack(spacing: 16) {
                            if let profileURL = postUser?.profile_image_url,
                               let url = URL(string: profileURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable()
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
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(postUser?.name ?? "익명")
                                    .font(.title3)
                                    .bold()
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding()
                        
                        if postDetails?.user_idx == userManager.userId {
                                Picker("", selection: $selectedStatus) {
                                    ForEach(statusOptions, id: \.self) { status in
                                        Text(status)
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(Color.black)
                                            .bold()
                                            .tag(status)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: selectedStatus) { newValue in
                                    // post_status 상태 변경 로직
                                }
                                .padding()
                                .background(Color.white)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 3)
                                }
                                .cornerRadius(8)
                                .padding(.trailing, 200)
                            }

                        
                        // 게시물 제목 및 설명
                        VStack(alignment: .leading, spacing: 10) {
                            Text(postDetails?.title ?? "제목 없음")
                                .font(.title)
                                .bold()
                                .padding(.trailing, 130)
                            
                            HStack {
                                Text("#\(postDetails?.post_category ?? "카테고리 없음")")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                
                                Text("#\(postDetails?.post_categoryType ?? "카테고리 타입 없음")")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 200)
                        }
                        
                        Text(postDetails?.post_content ?? "내용 없음")
                            .font(.title3)
                            .padding(.trailing)
                            .padding()
                        
                        // 거래 정보 (장소 및 인원수)
                        HStack {
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("장소: \(postDetails?.location ?? "장소 미정")")
                                }
                                
                                HStack {
                                    Image(systemName: "person.2.fill")
                                    Text("인원수: \(postDetails?.want_num ?? 0)명")
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 30)
                        
                        Divider()
                        
                    }
                    .padding(.vertical)
                    
                }
                
                VStack(spacing: 0) {
                    
                    Divider()
                    
                    HStack {
                        // 게시물 찜하기
                        Button(action:{
                            
                        }){
                            Image(systemName: "heart.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 30)
                                .foregroundColor(.black)
                        }
                        .padding()
                        
                        Spacer()
                        
                        // 채팅하기 버튼
                        Button(action: {
                            // 채팅하기 버튼 액션
                        }) {
                            Text("채팅하기")
                                .font(.title3)
                                .frame(width: 80)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.leading)
                        }
                        .padding()
                    }
                }
                
            }
        }
    }

}
        

#Preview {
    DetailPost(post_idx: "sq0M7IBzRVAhiax2UXbj")
        .environmentObject(UserManager())
}
