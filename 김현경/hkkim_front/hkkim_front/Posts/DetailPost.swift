//  DetailPost : 공구/나눔 게시글 디테일

import SwiftUI

func timeAgo(from date: Date?) -> String{
    guard let date = date else { return "알 수 없음" }
    
    let now = Date()
    let interval = now.timeIntervalSince(date)
    
    if interval < 60 {
        return "\(Int(interval))초 전"
    }
    else if interval < 3600 {
        return "\(Int(interval / 60))분 전"
        }
    else if interval < 86400 {
            return "\(Int(interval / 3600))시간 전"
        }
    else if interval < 2592000 {
            return "\(Int(interval / 86400))일 전"
        }
    else if interval < 31536000 {
            return "\(Int(interval / 2592000))개월 전"
        }
    else {
            return "\(Int(interval / 31536000))년 전"
        }
}

struct DetailPost: View {
    @EnvironmentObject var userManager: UserManager
    var post_idx: String // 전달받은 post_idx
    
    @State private var postDetails: PostInfo?
    @State private var postImages: [PostImages] = []
    @State private var postUser: UserProperty?
    @State private var currentImageIndex = 0
    @State private var isLoading = true
    @State private var isLiked = false
    @State private var isActionSheetPresented = false
    @State private var isEditPostPresented = false // 수정 화면 표시 여부
    
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
    
    private func toggleLike(){
        guard let userIdx = userManager.userId else { return }
        firestoreService.togglePostLike(postIdx: post_idx, userIdx: userIdx, isLiked: isLiked){
            result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    isLiked.toggle()
                }
            case .failure(let error):
                print("Error toggling post like: \(error)")
            }
        }
    }
    
    private func checkIfLiked(){
        guard let userIdx = userManager.userId else { return }
        firestoreService.isPostLiked(postIdx: post_idx, userIdx: userIdx){ liked in
            DispatchQueue.main.async {
                self.isLiked = liked
            }
        }
    }
    
    private func updatePostStatus(to status: String) {
        firestoreService.updatePostStatus(postIdx: post_idx, newStatus: status) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.selectedStatus = status // Firestore 업데이트 후 상태 반영
                }
            case .failure(let error):
                print("Error updating post status: \(error)")
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
                VStack {
                    if postDetails?.user_idx == userManager.userId {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                isActionSheetPresented = true
                            }) {
                                Image("appSetting")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50)
                            }
                        }
                    }
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
                                                        .frame(height: 200)
                                                        .clipped()
                                                case .failure:
                                                    Image("NoImage")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: .infinity)
                                                        .frame( height: 200)
                                                        .clipped()
                                                @unknown default:
                                                    Image("NoImage")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 200)
                                                        .clipped()
                                                }
                                            }
                                        } else {
                                            Image("NoImage")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 200)
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
                                    print("Selected status changed to: \(newValue)")
                                    
                                    updatePostStatus(to: newValue)
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
                                
                                HStack {
                                    Text("#\(postDetails?.post_category ?? "카테고리 없음")")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                    
                                    Text("#\(postDetails?.post_categoryType ?? "카테고리 타입 없음")")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                    
                                    if let createdAt = postDetails?.created_at {
                                        Text(timeAgo(from: createdAt))
                                            .font(.title3)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("")
                                            .font(.title3)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.bottom, 30)
                                
                                Text(postDetails?.post_content ?? "내용 없음")
                                    .font(.title3)
                                    .padding(.bottom, 40)
                                
                                // 거래 정보 (장소 및 인원수)
                                HStack {
                                    VStack(spacing: 8) {
                                        HStack {
                                            Image(systemName: "mappin.and.ellipse")
                                            
                                            Text("장소: \(postDetails?.location ?? "장소 미정")")
                                                .bold()
                                        }
                                        
                                        HStack {
                                            Image(systemName: "person.2.fill")
                                            Text("거래 희망 인원수: \(postDetails?.want_num ?? 0)명")
                                                .bold()
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            Divider()
                            
                        }
                        .padding(.vertical)
                        
                    }
                }
                
                VStack(spacing: 0) {
                    
                    Divider()
                    
                    HStack {
                        // 게시물 찜하기
                        Button(action:{
                            toggleLike()
                        }){
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 30)
                                .foregroundColor(selectedStatus == "거래완료" ? .gray : .black)
                        }
                        .disabled(selectedStatus == "거래완료")
                        .padding()
                        .onAppear {
                            checkIfLiked()
                        }
                        
                        Spacer()
                        
                        // 채팅하기 버튼
                        Button(action: {
                            // 채팅하기 버튼 액션
                        }) {
                            Text("채팅하기")
                                .font(.title3)
                                .frame(width: 80)
                                .padding()
                                .background(selectedStatus == "거래완료" ? Color.gray : Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.leading)
                        }
                        .disabled(selectedStatus == "거래완료")
                        .padding()
                    }
                    .background(Color.white)
                }
                
            }
            .actionSheet(isPresented: $isActionSheetPresented){
                ActionSheet(
                    title: Text(""),
                    message: nil,
                    buttons: [
                        .default(Text("게시물 수정"), action: {
                            // 게시물 수정
                            isEditPostPresented = true
                        }),
                        .destructive(Text("게시물 삭제"), action: {
                            // 게시물 삭제 동작
                        }),
                        .cancel(Text("취소"))
                    ]
                )
            }
            .sheet(isPresented: $isEditPostPresented){
                if let postDetails = postDetails {
                    CreatePostView(
                        post: CreatePost(
                            post_idx: postDetails.id ?? "", // Firestore 문서 ID
                            user_idx: postDetails.user_idx,
                            post_category: postDetails.post_category,
                            post_categoryType: postDetails.post_categoryType,
                            title: postDetails.title,
                            post_content: postDetails.post_content,
                            location: postDetails.location,
                            want_num: postDetails.want_num,
                            post_status: postDetails.post_status,
                            created_at: postDetails.created_at ?? Date(), // 기본값 제공
                            school_idx: postDetails.school_idx,
                            postImages: postDetails.images?.map {
                                CreatePostImage(post_idx: $0.post_idx, image_url: $0.image_url)
                            } ?? [] // 기본값 빈 배열 제공
                        ),
                        isEditMode: true // 수정 모드 활성화
                    )
                }
            }
        }
    }

}
        

#Preview {
    DetailPost(post_idx: "sq0M7IBzRVAhiax2UXbj")
        .environmentObject(UserManager())
}
