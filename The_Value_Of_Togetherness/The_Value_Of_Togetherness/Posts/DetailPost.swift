//  DetailPost : 공구/나눔 게시글 디테일
import SwiftUI
import FirebaseFirestore

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

func getCurrentTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}

struct ChattingRoom: Identifiable {
   var id: String
   var postIdx: String
   var hostIdx: String
   var guestIdx: String
   var isHostLeft: Bool
   var isGuestLeft: Bool
   var roomState: Bool
}


struct DetailPost: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    var post_idx: String // 전달받은 post_idx
    
    @State private var postDetails: PostInfo?
    @State private var postImages: [PostImages] = []
    @State private var postUser: UserProperty?
    @State private var currentImageIndex = 0
    @State private var isLoading = true
    @State private var isLiked = false
    @State private var isActionSheetPresented = false
    @State private var isEditPostPresented = false // 수정 화면 표시 여부
    @State private var selectedStatus = ""
    let statusOptions = ["거래가능", "거래완료"]
    
    @State private var chatRoomId: String?
    @State private var isChatRoomCreated = false // 채팅방 생성 상태
    @State private var navigateToChatRoom = false // 채팅방으로 이동을 위한 상태
    @State private var navigateToChatList = false //ChatListMain으로 이동 상태
    @State private var showAlert2 = false //경고창
    @State private var alertMessage2 = " "
    
    @State private var comments: [Comments] = [] // 댓글 리스트
    @State private var commentText: String = "" // 댓글 입력 텍스트
    @State private var replyText: String = "" // 대댓글 입력 텍스트
    @State private var replyToCommentIdx: String = "" // 대댓글 대상 댓글 ID
    @State private var isReplying: Bool = false // 대댓글 작성 상태
    
    // 게시물 삭제 관련 알림
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var db = Firestore.firestore()
    private let firestoreService = DetailPostFirestoreService()
    
    var isPostOwner: Bool {
        //현재 로그인 유저가 게시물 작성자인지 확인
        return postUser?.user_idx == userManager.userId
    }
    
    private func fetchData() {
        firestoreService.fetchPostDetails(postIdx: post_idx) { result in
            switch result {
            case .success(let post):
                DispatchQueue.main.async {
                    self.postDetails = post
                    self.selectedStatus = post.post_status
                }
                if let postId = post.id {
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
        
        //채팅방 존재 여부 확인
        checkExistingChatRoom()
    }
    
    private func fetchImages(for postIdx: String) {
        firestoreService.fetchPostImages(postIdx: postIdx) { result in
            switch result {
            case .success(let images):
                DispatchQueue.main.async {
                    self.postImages = images
                    self.postDetails?.images = images // postDetails에 이미지 추가
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
    
    private func fetchComments(for postIdx: String) {
        firestoreService.fetchComments(postIdx: postIdx) { result in
            switch result {
            case .success(let enrichedComments):
                DispatchQueue.main.async {
                    self.comments = enrichedComments
                }
            case .failure(let error):
                print("Error fetching comments: \(error)")
            }
        }
    }
    
    private func fetchCommentUserDetails(for userIdx: String, completion: @escaping (UserProperty?) -> Void) {
        firestoreService.fetchUserDetails(userIdx: userIdx) { result in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                print("Error fetching comment user details: \(error)")
                completion(nil)
            }
        }
    }
    
    private func addComment(content: String) {
        guard let userIdx = userManager.userId else { return }
        firestoreService.addComment(postIdx: post_idx, userIdx: userIdx, content: content) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.commentText = ""
                    self.fetchComments(for: post_idx)
                }
            case .failure(let error):
                print("Error adding comment: \(error)")
            }
        }
    }
    
    private func addReply(to commentIdx: String, content: String) {
        guard let userIdx = userManager.userId else { return }
        firestoreService.addReply(commentIdx: commentIdx, postIdx: post_idx, userIdx: userIdx, content: content) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.fetchComments(for: post_idx) // 새로고침
                }
            case .failure(let error):
                print("Error adding reply: \(error)")
            }
        }
    }
    
    //채팅방 중복 체크 및 생성
    private func checkExistingChatRoom(){
        guard let currentUserId = userManager.userId else{
            print("로그인된 유저 없음")
            return
        }
        // Firestore에서 해당 채팅방이 이미 존재하는지 확인
        db.collection("chattingRooms").whereField("post_idx", isEqualTo: post_idx)
            .whereField ("guest_idx", isEqualTo: currentUserId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("채팅방 확인 중 오류 발생: \(error.localizedDescription)")
                } else {
                    if snapshot?.documents.isEmpty == false {
                        /// 이미 채팅방이 존재하면 해당 채팅방 ID를 가져오고, 상태 업데이트
                        if let document = snapshot?.documents.first{
                            self.chatRoomId = document.documentID
                            self.isChatRoomCreated = true //채팅방 생성 상태로 설정
                            print("채팅방 이미 존재: \(self.chatRoomId!)")
                        } else{
                            print("채팅방 없음")
                        }
                    }
                }
            }
    }
    
    //채팅방생성
    private func createChatRoom(){
        guard let currentUserId = userManager.userId else{
            print("로그인된 유저 없음")
            return
        }
        //Firestore의 chattingRooms 컬렉션에 새 채팅방 정보 추가
        let chatRoomData: [String: Any] = [
            "post_idx": post_idx,
            "host_idx": postUser?.user_idx ?? "",
            "guest_idx": currentUserId,
            "isHostLeft": false,
            "isGuestLeft": false,
            "roomState": false
        ]
        // 채팅방 정보 Firestore에 저장
        db.collection("chattingRooms").addDocument(data: chatRoomData) { error in
            if let error = error {
                print("채팅방 생성 중 오류 발생: \(error.localizedDescription)")
            } else {
                print("채팅방이 성공적으로 생성되었습니다.")
                // 채팅방이 성공적으로 생성되면 해당 채팅방으로 이동
                loadChatRoomId()
                //self.navigateToChatRoom = true
            }
        }
    }
    
    //생성된 채팅방 ID 로드
    private func loadChatRoomId(){
        db.collection("chattingRooms").whereField("post_idx", isEqualTo: post_idx)
            .whereField("guest_idx", isEqualTo: userManager.userId ?? "")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("채팅방 ID를 불러오는 중 오류 발생: \(error.localizedDescription)")
                } else {
                    if let document = snapshot?.documents.first {
                        chatRoomId = document.documentID
                        self.isChatRoomCreated = true // 채팅방 생성 상태로 설정
                        //채팅방이 생성되면 화면 이동 트리거
                        DispatchQueue.main.async {
                            print("채팅방 생성됨, ID: \(self.chatRoomId!)")
                            self.navigateToChatRoom = true
                        }
                    } else{
                        print("채팅방을 불러오는 데 실패했습니다.")
                    }
                }
            }
    }
    
    private func checkChatList() {
        db.collection("chattingRooms")
            .whereField("post_idx", isEqualTo: post_idx)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("채팅방 확인 오류: \(error.localizedDescription)")
                } else if let documents = snapshot?.documents {
                    // isGuestLeft가 false인 채팅방만 필터링
                    let activeChatRooms = documents.filter { document in
                        let data = document.data()
                        return !(data["isHostLeft"] as? Bool ?? true) // isHostLeft가 false인 방만 포함
                    }
                    
                    if !activeChatRooms.isEmpty {
                        // 활성화된 채팅방이 있을 경우 ChatListMain으로 이동
                        DispatchQueue.main.async {
                            navigateToChatList = true
                        }
                    } else {
                        // 활성화된 채팅방이 없을 경우 경고창 표시
                        DispatchQueue.main.async {
                            alertMessage2 = "게시물에 대한 채팅 목록이 없습니다."
                            showAlert2 = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        alertMessage2 = "게시물에 대한 채팅 목록이 없습니다."
                        showAlert2 = true
                    }
                }
            }
    }
    
    var body: some View {
        if isLoading {
            ProgressView("Loading....")
                .onAppear {
                    fetchData()
                    fetchImages(for: post_idx)
                    fetchComments(for: post_idx)
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
                                                        .frame(height: 400)
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
                                Image("NoImage")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipped()
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
                            
                            if let postDetails = postDetails {
                                if postDetails.user_idx == userManager.userId { // 게시물 소유자 확인
                                    Picker("", selection: $selectedStatus) {
                                        ForEach(statusOptions, id: \.self) { status in
                                            Text(status)
                                                .font(.title2)
                                                .bold()
                                                .foregroundColor(Color.black)
                                                .tag(status)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .onChange(of: selectedStatus) { newValue in
                                        if newValue != postDetails.post_status {
                                            print("Selected status changed to: \(newValue)")
                                            updatePostStatus(to: newValue)
                                        }
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
                            }
                            
                            // 게시물 제목 및 설명
                            VStack(alignment: .leading, spacing: 10) {
                                    
                                Text(postDetails?.title ?? "제목 없음")
                                    .font(.title)
                                    .bold()
    
                                if postDetails?.user_idx != userManager.userId {
                                    Text("\(postDetails?.post_status ?? "상태 없음")")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.gray)
                                }
                                
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
                                    VStack(spacing: 10) {
                                        HStack {
                                            Image(systemName: "mappin.and.ellipse")
                                            
                                            Text("거래 희망 장소 : \(postDetails?.location ?? "미정")")
                                                .bold()
                                        }
                                        
                                        HStack {
                                            Image(systemName: "person.2.fill")
                                            Text("거래 희망 인원수 : \(postDetails?.want_num ?? 0) 명")
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
                            
                            // 댓글 대댓글 리스트
                            CommentsSection(comments: $comments, post_idx: post_idx) { commentIdx in
                                replyToCommentIdx = commentIdx
                                isReplying = true
                            }
                            .environmentObject(UserManager())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            // 댓글, 대댓글 작성
                            CommentInput(
                                isReplying: isReplying,
                                commentText: $commentText,
                                replyText: $replyText,
                                onSubmitComment: {
                                    addComment(content: commentText)
                                    commentText = ""
                                },
                                onSubmitReply: {
                                    addReply(to: replyToCommentIdx, content: replyText)
                                    replyText = ""
                                    isReplying = false
                                },
                                onCancelReply: {
                                    isReplying = false
                                    replyText = ""
                                }
                            )
                            
                            Spacer().frame(height: 60) // 하단 여유 공간 추가
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
                                .foregroundColor(selectedStatus == "거래완료" ? Color.gray : Color.black)
                        }
                        .disabled(selectedStatus == "거래완료")
                        .padding()
                        .onAppear {
                            checkIfLiked()
                        }
                        
                        Spacer()
                        
                        // 채팅하기 버튼
                        if isPostOwner{
                            Button(action: checkChatList){
                                Text("채팅 목록")
                                    .font(.headline)
                                    .frame(width: 120)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding()
                        } else {
                            Button(action: {
                                if !isChatRoomCreated {
                                    createChatRoom()
                                }
                                self.navigateToChatRoom = true
                            }) {
                                Text( !isChatRoomCreated ? "채팅하기" : "채팅방으로 이동")
                                    .font(.headline)
                                    .frame(width: 80)
                                    .padding()
                                    .background(selectedStatus == "거래완료" && !isChatRoomCreated ? Color.gray : Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding(.leading)
                            }
                            .disabled(selectedStatus == "거래완료" && !isChatRoomCreated)
                            .padding()
                        }
                        
                        // 채팅방으로 이동
                        if let chatRoomId = chatRoomId {
                            NavigationLink(
                                destination: ChatView(postIdx: post_idx, chatRoomId: chatRoomId)
                                    .environmentObject(userManager),
                                isActive: $navigateToChatRoom
                            ) {
                                EmptyView()
                            }
                        }
                        
                        NavigationLink(
                            destination: ChatListMain(selectedCategory: "내 게시물 채팅 목록", selectedPostId: post_idx).environmentObject(userManager),
                            isActive: $navigateToChatList
                        ) {
                            EmptyView()
                        }
                        
                    }
                    .background(Color.white)
                }
                .onAppear {
                    fetchData() // 데이터 로드
                }
            }
            .actionSheet(isPresented: $isActionSheetPresented){
                ActionSheet(
                    title: Text(""),
                    message: nil,
                    buttons: [
                        .default(Text("게시물 수정"), action: {
                            isEditPostPresented = true // 게시물 수정
                        }),
                        .destructive(Text("게시물 삭제"), action: {
                            firestoreService.deletePost(postIdx: post_idx) { success in
                                if success {
                                    alertMessage = "게시물이 성공적으로 삭제되었습니다."
                                    showAlert = true
                                } else {
                                    alertMessage = "게시물 삭제에 실패했습니다. 다시 시도해주세요."
                                    showAlert = true
                                }
                            }
                        }),
                        .cancel(Text("취소"))
                    ]
                )
            }
            .sheet(isPresented: $isEditPostPresented, onDismiss: {
                fetchData() // CreatePostView 닫힌 후 데이터 새로고침
            }){
                if let postDetails = postDetails {
                    CreatePostView(post: postDetails.toCreatePost(), postDetails: $postDetails, isEditMode: true)
                }
            }
            .alert(isPresented: $showAlert2){
                Alert(title: Text("알림"), message: Text(alertMessage2), dismissButton: .default(Text("확인")))
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인")) {
                        if alertMessage == "게시물이 성공적으로 삭제되었습니다." {
                            dismiss()
                        }
                    }
                )
            }
        }
    }
    
    init(post_idx: String) {
        self.post_idx = post_idx
    }
}
        

#Preview {
    DetailPost(post_idx: "sq0M7IBzRVAhiax2UXbj")
        .environmentObject(UserManager())
}
