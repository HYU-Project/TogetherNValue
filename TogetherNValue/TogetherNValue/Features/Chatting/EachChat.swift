import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import Combine

struct ChatView: View {
    @EnvironmentObject var userManager: UserManager
    var postIdx: String
    var chatRoomId: String
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @State private var postDetails: FetchPostInfo?  // 게시물 정보
    @State private var postImages: [PostImage] = []  // 게시물 이미지 목록
    @State private var isLoading = true
    @State private var roomState: Bool = false

    
    @State private var isShowingPhotoOptions = false
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCamera = false
    @State private var isShowingActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var showTransactionAlert = false // 거래 완료 확인창
    @State private var isHost: Bool = false //현재 사용자가 호스트인가?
    
    //@State private var unreadCount: Int = 0
    
    //@ObservedObject var viewModel: ChatListViewModel
    @Environment(\.presentationMode) var presentationMode  // presentationMode를 통해 뷰를 닫기 위함
    private var db = Firestore.firestore()

    var body: some View {
        VStack {
            // 게시물 정보 분리된 뷰
            PostInfoView(postDetails: postDetails, postImages: postImages, postIdx: postIdx, isShowingActionSheet: $isShowingActionSheet, getActionSheetButtons: getActionSheetButtons)

            // 메시지 리스트 분리
            ScrollView {
                ForEach(messages) { message in
                    ChatMessageView(message: message, formatTimestamp: formatTimestamp)
                }
            }
            
            // 입력창
            ChatInputView(newMessage: $newMessage,
                          isShowingPhotoOptions: $isShowingPhotoOptions,
                          isShowingPhotoPicker: $isShowingPhotoPicker,
                          isShowingCamera: $isShowingCamera,
                          sendMessageAction: { sendMessage(text: newMessage) })
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            loadMessages()
            loadPostDetails()
            checkIfCurrentUserIsHost()
            fetchRoomState()
            //markMessagesAsRead()
        }
        .sheet(isPresented: $isShowingPhotoPicker) { // 앨범 시트
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
        .sheet(isPresented: $isShowingCamera) { // 카메라 시트
            ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let imageToSend = newImage {
                sendMessage(image: imageToSend)
            }
        }
        .alert(isPresented: $showTransactionAlert) {
                if roomState { // 거래 완료된 상태
                    return Alert(
                        title: Text("거래 완료"),
                        message: Text("이미 거래를 완료하셨습니다."),
                        dismissButton: .default(Text("확인"))
                    )
                } else { // 거래 미완료 상태
                    return Alert(
                        title: Text("거래 완료"),
                        message: Text("거래를 완료하시겠습니까?"),
                        primaryButton: .default(Text("확인")) {
                            completeTransaction()
                        },
                        secondaryButton: .cancel()
                    )
                }
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
                    let data = document.data()
                    guard let imageUrl = data["image_url"] as? String else {
                        return nil
                    }
                    return PostImage(id: document.documentID, image_url: imageUrl)
                }
            }
        }
    }


    func loadMessages() {
        db.collection("chattingRooms")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("메시지 로드 오류: \(error.localizedDescription)")
                } else {
                    self.messages = snapshot?.documents.compactMap { document in
                        let data = document.data()
                        if let senderID = data["senderID"] as? String,
                           let messageText = data["messageText"] as? String,
                           let timestamp = data["timestamp"] as? Timestamp {
                            
                            let imageUrl = data["imageUrl"] as? String  // Optional 처리
                            
                            return Message(
                                id: document.documentID,
                                senderID: senderID,
                                text: messageText,
                                isCurrentUser: senderID == userManager.userId,
                                timestamp: timestamp.dateValue(),
                                imageUrl: imageUrl
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

    // firestore에 text or image 전송
    func sendMessage(text: String? = nil, image: UIImage? = nil) {
        guard let currentUserId = userManager.userId else {
            print("로그인된 사용자가 없습니다.")
            return
        }

        if let image = image {
            // 1. 이미지 업로드 후 메시지 전송
            let storageRef = Storage.storage().reference()
            let imageName = UUID().uuidString + ".jpg"
            let imageRef = storageRef.child("chat_images/\(imageName)")

            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("이미지 업로드 실패: \(error.localizedDescription)")
                    return
                }

                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("URL 가져오기 실패: \(error.localizedDescription)")
                        return
                    }

                    guard let downloadUrl = url else { return }

                    let messageData: [String: Any] = [
                        "senderID": currentUserId,
                        "messageText": "",
                        "imageUrl": downloadUrl.absoluteString,
                        "timestamp": Timestamp()
                    ]

                    db.collection("chattingRooms")
                        .document(chatRoomId)
                        .collection("messages")
                        .addDocument(data: messageData) { error in
                            if let error = error {
                                print("이미지 메시지 저장 실패: \(error.localizedDescription)")
                            } else {
                                print("이미지 메시지 저장 성공")
                                selectedImage = nil
                            }
                        }
                }
            }
        } else if let text = text, !text.isEmpty {
            // 텍스트 메시지 전송
            let messageData: [String: Any] = [
                "senderID": currentUserId,
                "messageText": text,
                "timestamp": Timestamp()
            ]

            db.collection("chattingRooms")
                .document(chatRoomId)
                .collection("messages")
                .addDocument(data: messageData) { error in
                    if let error = error {
                        print("텍스트 메시지 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("텍스트 메시지 저장 성공")
                    }
                }

            let newMessageObj = Message(
                id: UUID().uuidString,
                senderID: currentUserId,
                text: text,
                isCurrentUser: true,
                timestamp: Date(),
                imageUrl: nil
            )

            messages.append(newMessageObj)
            newMessage = ""
            saveMessages()
        }
    }

    
//    func fetchUnreadMessageCount(){
//        guard let currentUserId = userManager.userId else {return}
//        db.collection("chattingRooms")
//            .document(chatRoomId)
//            .collection("messages")
//            .whereField("isRead", isEqualTo: false)
//            .whereField("senderID",isNotEqualTo: currentUserId)
//            .getDocuments{ snapshot, error in
//                if let error = error{
//                    print("읽지 않은 메시지 개수 가져오기 오류: \(error.localizedDescription)")
//                }else{
//                    self.unreadCount = snapshot?.documents.count ?? 0
//                    print("읽지 않은 메시지 개수: \(unreadCount)")
//                }
//            }
//    }
    
//    func markMessagesAsRead() {
//        guard let currentUserId = userManager.userId else { return }
//        let query = db.collection("chattingRooms")
//            .document(chatRoomId)
//            .collection("messages")
//            .whereField("isRead", isEqualTo: false)
//            .whereField("senderID", isNotEqualTo: currentUserId)
//
//        query.getDocuments { snapshot, error in
//            if let error = error {
//                print("메시지 읽음 업데이트 오류: \(error.localizedDescription)")
//            } else {
//                let batch = db.batch()
//                snapshot?.documents.forEach { document in
//                    batch.updateData(["isRead": true], forDocument: document.reference)
//                }
//                batch.commit { error in
//                    if let error = error {
//                        print("읽음 상태 업데이트 실패: \(error.localizedDescription)")
//                    } else {
//                        print("읽음 상태 업데이트 성공")
//                    }
//                }
//            }
//        }
//    }
    
//    func observeMessages() {
//        db.collection("chattingRooms")
//            .document(chatRoomId)
//            .collection("messages")
//            .order(by: "timestamp")
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("메시지 감지 오류: \(error.localizedDescription)")
//                } else {
//                    self.messages = snapshot?.documents.compactMap { document in
//                        let data = document.data()
//                        if let senderID = data["senderID"] as? String,
//                           let messageText = data["messageText"] as? String,
//                           let timestamp = data["timestamp"] as? Timestamp,
//                           let isRead = data["isRead"] as? Bool {
//                            return Message(
//                                id: document.documentID,
//                                senderID: senderID,
//                                text: messageText,
//                                isCurrentUser: senderID == userManager.userId,
//                                timestamp: timestamp.dateValue(),
//                                isRead: isRead
//                            )
//                        }
//                        return nil
//                    } ?? []
//                    markMessagesAsRead() // 메시지 실시간 로드 후 읽음 처리
//                }
//            }
//    }


    
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    func saveMessages() {
        let messageDicts = messages.map { message in
            return [
                "id": message.id ?? "",
                "senderID": message.senderID,
                "text": message.text,
                "isCurrentUser": message.isCurrentUser,
                "timestamp": message.timestamp.timeIntervalSince1970,
                "imageUrl": message.imageUrl ?? ""
            ] as [String : Any]
        }

        UserDefaults.standard.set(messageDicts, forKey: "messages_\(chatRoomId)")
    }

    
    func completeTransaction() {
        // Firestore에서 roomState를 확인
        db.collection("chattingRooms")
            .document(chatRoomId)
            .getDocument { document, error in
                if let error = error {
                    print("거래 완료 상태 확인 오류: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, let data = document.data(),
                   let currentState = data["roomState"] as? Bool, currentState {
                    print("거래가 이미 완료된 상태입니다.")
                    return // 이미 완료된 경우 종료
                }
                
                // roomState 업데이트
                self.db.collection("chattingRooms")
                    .document(chatRoomId)
                    .updateData(["roomState": true]) { error in
                        if let error = error {
                            print("거래 완료 상태 업데이트 실패: \(error.localizedDescription)")
                        } else {
                            print("거래 완료 상태 업데이트 성공")
                            self.addCompletionMessage()
                        }
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
    
    func fetchRoomState() {
        db.collection("chattingRooms")
            .document(chatRoomId)
            .getDocument { document, error in
                if let error = error {
                    print("거래 상태 가져오기 오류: \(error.localizedDescription)")
                    return
                }

                if let document = document, let data = document.data(),
                    let currentState = data["roomState"] as? Bool {
                    DispatchQueue.main.async {
                        self.roomState = currentState
                    }
                } else {
                    print("거래 상태 로드 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
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


#Preview {
    let userManager = UserManager()
    ChatView(postIdx: "PUYPuhmRrl7adGojXJbz", chatRoomId:"lHMhLxLWC0VqAOS1jSJy")
        .environmentObject(userManager)
}
