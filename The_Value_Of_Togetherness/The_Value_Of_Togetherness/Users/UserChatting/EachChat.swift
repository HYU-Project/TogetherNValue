import SwiftUI
import FirebaseFirestore
import Combine

struct FetchPostInfo {
    var title: String
    var location: String
    var post_status: String
}

struct PostImage: Identifiable, Codable {
    @DocumentID var id: String?
    var image_url: String
}

// Message 구조체 정의
struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let senderID: String
    let text: String
    let isCurrentUser: Bool
    let timestamp: Date
}

struct ChatView: View {
    @EnvironmentObject var userManager: UserManager
    var postIdx: String
    var chatRoomId: String
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @State private var postDetails: FetchPostInfo?  // 게시물 정보
    @State private var postImages: [PostImage] = []  // 게시물 이미지 목록
    @State private var isLoading = true
    
    @State private var isShowingPhotoOptions = false
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCamera = false
    @State private var isShowingActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var showTransactionAlert = false // 거래 완료 확인창
    @State private var isHost: Bool = false //현재 사용자가 호스트인가?
    
    //@ObservedObject var viewModel: ChatListViewModel
    @Environment(\.presentationMode) var presentationMode  // presentationMode를 통해 뷰를 닫기 위함
    private var db = Firestore.firestore()

    var body: some View {
        VStack {
            // 게시물 정보 표시
            if let postDetails = postDetails {
                HStack {
                    // 게시물 이미지 (첫 번째 이미지)
                    if let firstImage = postImages.first, let imageURL = URL(string: firstImage.image_url) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                            @unknown default:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipped()
                    }

                    VStack(alignment: .leading) {
                        Text(postDetails.title)
                            .font(.headline)
                        Text(postDetails.location)
                            .font(.subheadline)
                        Text(postDetails.post_status)
                            .font(.subheadline)
                            .foregroundColor(postDetails.post_status == "거래중" ? .green : .red)
                    }
                                
                    Spacer()
                
                    // 옵션 선택 버튼
                    Button(action: {
                        isShowingActionSheet = true
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
                    }
                    .padding()
                    .actionSheet(isPresented: $isShowingActionSheet) {
                        ActionSheet(
                            title: Text("옵션 선택"),
                            buttons: getActionSheetButtons()
                        )
                    }
                }
                .padding()
            } else {
                Text("게시물 정보를 불러오는 중...")
                    .padding()
            }

            ScrollView {
                ForEach(messages) { message in
                    VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4){
                        HStack {
                            if message.senderID == "system"{
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.black)
                                Spacer()
                            }else if message.isCurrentUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }
                        if message.senderID != "system" {
                            Text(formatTimestamp(message.timestamp)) // 메시지 보낸 시간 표시
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
            }

            HStack {
                Button(action: {
                    isShowingPhotoOptions = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                        .foregroundColor(.blue)
                }
                .actionSheet(isPresented: $isShowingPhotoOptions) {
                    ActionSheet(
                        title: Text("사진 추가"),
                        buttons: [
                            .default(Text("앨범에서 선택")) {
                                isShowingPhotoPicker = true
                            },
                            .default(Text("카메라 열기")) {
                                isShowingCamera = true
                            },
                            .cancel()
                        ]
                    )
                }

                TextField("메시지를 입력하세요", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button(action: sendMessage) {
                    Text("전송")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            loadMessages()
            loadPostDetails()
            checkIfCurrentUserIsHost()
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            ImagePicker(sourceType: isShowingCamera ? .camera : .photoLibrary, selectedImage: $selectedImage)
        }
        .alert(isPresented: $showTransactionAlert) {
            Alert(
                title: Text("거래 완료"),
                message: Text("거래를 완료하시겠습니까?"),
                primaryButton: .default(Text("확인")) {
                    completeTransaction()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // Firestore에서 게시물 정보 로드
    func loadPostDetails() {
        db.collection("posts").document(postIdx).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let title = data?["title"] as? String,
                   let location = data?["location"] as? String,
                   let postStatus = data?["post_status"] as? String {
                    // 게시물 데이터를 상태에 저장
                    self.postDetails = FetchPostInfo(title: title, location: location, post_status: postStatus)
                }
                // 게시물 이미지 가져오기
                fetchPostImages()
            } else {
                print("게시물을 찾을 수 없습니다: \(error?.localizedDescription ?? "알 수 없는 오류")")
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    // Firestore에서 게시물 이미지 목록 로드
    func fetchPostImages() {
        db.collection("posts").document(postIdx).collection("postImages").getDocuments { snapshot, error in
            if let error = error {
                print("게시물 이미지 로드 실패: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                self.postImages = snapshot.documents.compactMap { document in
                    try? document.data(as: PostImage.self)
                }
            }
        }
    }

    
    func loadMessages() {
        db.collection("chattingRooms")
            .document(chatRoomId)  // 해당 채팅방의 documentId
            .collection("messages")  // 'messages' 서브컬렉션
            .order(by: "timestamp")  // 타임스탬프 기준으로 정렬
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("메시지 로드 오류: \(error.localizedDescription)")
                } else {
                    self.messages = snapshot?.documents.compactMap { document in
                        let data = document.data()
                        if let senderID = data["senderID"] as? String,
                           let messageText = data["messageText"] as? String,
                           let timestamp = data["timestamp"] as? Timestamp {
                            return Message(
                                id: document.documentID,
                                senderID: senderID,
                                text: messageText,
                                isCurrentUser: senderID == userManager.userId,
                                timestamp: timestamp.dateValue()
                            )
                        }
                        return nil
                    } ?? []
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
    }

    // 메세지 Firebase Firestore에 저장
    func sendMessage() {
        guard let currentUserId = userManager.userId else {
            print("로그인된 사용자가 없습니다.")
            return
        }
        
        let newMessageObj = Message(
            id: UUID().uuidString,
            senderID: currentUserId,
            text: newMessage,
            isCurrentUser: true,
            timestamp: Date()
        )
        messages.append(newMessageObj)
        
        //Firestore에 메세지 추가
        let messageData: [String: Any] = [
            "senderID": userManager.userId ?? "",
            "messageText": newMessage,
            "timestamp": Timestamp()
        ]
        
        db.collection("chattingRooms")
            .document(chatRoomId)
            .collection("messages")
            .addDocument(data: messageData){ error in
                if let error = error {
                    print("메시지 전송 오류: \(error.localizedDescription)")
                } else{
                    print("메시지가 Firestore에 성공적으로 저장됨")
                }
            }
        
        newMessage = "" //메세지 입력 초기화
        saveMessages()
    }
    
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    func saveMessages() {
        if let encodedData = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encodedData, forKey: "messages_\(chatRoomId)")
        }
    }

    
    func completeTransaction() {
        //거래 완료 로직
        db.collection("chattingRooms")
            .document(chatRoomId)
            .updateData(["roomState": true]){ error in
                if let error = error{
                    print("거래완료상태 업데이트 실패: \(error.localizedDescription)")
                }else{
                    print("거래완료상태 업데이트 성공")
                    self.addCompletionMessage()
                }
            }
    }
    
    func addCompletionMessage(){
        let completionMessage: [String: Any] = [
            "senderID": "system",
            "messageText": "거래가 완료되었습니다.",
            "timestamp": Timestamp()
        ]
        db.collection("chattingRooms")
            .document(chatRoomId)
            .collection("messages")
            .addDocument(data: completionMessage) { error in
                if let error = error {
                    print("거래 완료 메시지 추가 실패: \(error.localizedDescription)")
                }else{
                    print("거래 완료 메시지가 성공적으로 추가되었습니다.")
                }
            }
    }
    
    func leaveChatRoom() {
        // 채팅방 나가기 로직
        guard let currentUserId = userManager.userId else {
            print("오류: 로그인된 유저 없음")
            return
        }
        db.collection("chattingRooms")
            .document(chatRoomId)
            .getDocument{ document, error in
                if let error = error{
                    print("채팅방 데이터 로드 오류: \(error.localizedDescription)")
                    return
                }
                guard let data = document?.data() else {
                    print("채팅방 데이터가 존재하지 않음")
                    return
                    
                }
                
                let hostId = data["host_idx"] as? String
                let guestId = data["guest_idx"] as? String
                var updates: [String: Any] = [:]
                
                if currentUserId == hostId {
                    updates["isHostLeft"] = true
                } else if currentUserId == guestId {
                    updates["isGuestLeft"] = true
                } else {
                    print("오류: 현재 사용자는 해당 채팅방에 속하지 않음")
                    return
                }
                
                db.collection("chattingRooms")
                    .document(chatRoomId)
                    .updateData(updates) { error in
                        if let error = error {
                            print("채팅방 업데이트 오류: \(error.localizedDescription)")
                            return
                        }

                        print("채팅방 업데이트 성공: \(updates)")

                        // "상대방이 채팅방을 나갔습니다." 메시지 추가
                        addLeaveMessage()
                        // 모든 사용자가 나갔는지 확인 후 채팅방 삭제
                        checkAndDeleteChatRoom()
                        
                        DispatchQueue.main.async {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
            }
    }
    
    private func addLeaveMessage(){
        let leaveMessage: [String: Any] = [
            "senderID": "system",
            "messageText": "상대방이 채팅방을 나갔습니다.",
            "timestamp": Timestamp()
        ]
        db.collection("chattingRooms")
            .document(chatRoomId)
            .collection("messages")
            .addDocument(data: leaveMessage){ error in
                if let error = error {
                    print("사용자 나감 메시지 추가 실패: \(error.localizedDescription)")
                } else {
                    print("사용자 나감 메시지가 성공적으로 추가되었습니다.")
                }
            }
    }
    
    private func checkAndDeleteChatRoom() {
        db.collection("chattingRooms")
            .document(chatRoomId)
            .getDocument { document, error in
                if let error = error {
                    print("채팅방 삭제 조건 확인 중 오류 발생: \(error.localizedDescription)")
                    return
                }

                guard let data = document?.data() else {
                    print("채팅방 데이터를 찾을 수 없음")
                    return
                }

                let isHostLeft = data["isHostLeft"] as? Bool ?? false
                let isGuestLeft = data["isGuestLeft"] as? Bool ?? false

                if isHostLeft && isGuestLeft {
                    self.deleteChatRoom(chatRoomId: chatRoomId)
                }
            }
    }
    
    func deleteChatRoom(chatRoomId: String) {
        let chatRoomRef = db.collection("chattingRooms").document(chatRoomId)

        // 하위 컬렉션 "messages" 삭제
        chatRoomRef.collection("messages").getDocuments { snapshot, error in
            if let error = error {
                print("하위 컬렉션 삭제 실패: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("하위 컬렉션에 문서가 없습니다.")
                return
            }

            // 하위 컬렉션의 모든 문서 삭제
            let batch = self.db.batch()
            for document in documents {
                batch.deleteDocument(document.reference)
            }

            batch.commit { error in
                if let error = error {
                    print("하위 컬렉션 문서 삭제 실패: \(error.localizedDescription)")
                    return
                }

                print("하위 컬렉션의 모든 문서가 성공적으로 삭제되었습니다.")

                // 부모 문서 삭제
                chatRoomRef.delete { error in
                    if let error = error {
                        print("채팅방 문서 삭제 실패: \(error.localizedDescription)")
                    } else {
                        print("채팅방 문서 및 하위 컬렉션 삭제 성공")
                        verifyChatRoomDeletion(chatRoomId: chatRoomId)
                    }
                }
            }
        }
    }

    
    func verifyChatRoomDeletion(chatRoomId: String) {
        db.collection("chattingRooms")
            .document(chatRoomId)
            .getDocument { document, error in
                if let error = error {
                    print("삭제 확인 중 오류 발생: \(error.localizedDescription)")
                    return
                }

                if document?.exists == true {
                    print("문서가 여전히 존재합니다.")
                } else {
                    print("문서가 성공적으로 삭제되었습니다.")
                }
            }
    }
    
    func checkIfCurrentUserIsHost(){
        db.collection("chattingRooms")
            .document(chatRoomId)
            .getDocument{ document, error in
                if let document = document, document.exists{
                    let data = document.data()
                    if let hostId = data?["host_idx"] as? String {
                        self.isHost = (hostId == userManager.userId)
                    }
                }else {
                    print("채팅방 정보를 찾을 수 없습니다: \(error?.localizedDescription ?? "알 수 없는 오류")")
                }
            }
    }
    
    func getActionSheetButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = [
            .destructive(Text("채팅방 나가기")){
                leaveChatRoom()
            }
        ]
        
        if isHost{
            buttons.insert(
                .default(Text("거래 완료")){
                    showTransactionAlert = true
                },
                at: 0
            )
        }
        buttons.append(.cancel())
        
        return buttons
    }
    
    public init(postIdx: String, chatRoomId: String) {
            self.postIdx = postIdx
            self.chatRoomId = chatRoomId
        }

}




#Preview {
    let userManager = UserManager()
    ChatView(postIdx: "PUYPuhmRrl7adGojXJbz", chatRoomId:"lHMhLxLWC0VqAOS1jSJy")
        .environmentObject(userManager)
}
