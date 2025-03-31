//  ChatListMain : 채팅방 메인 화면 (채팅방 리스트)
import SwiftUI
import Firebase

struct chattingCategoryButtonView: View{
   @Binding var selectedCategory: String
   var body: some View{
       
       VStack {
           HStack {
               Text("채팅")
                   .font(.largeTitle)
                   .bold()
               Spacer()
           }
           .padding()
           
           HStack(spacing: 5){
               ForEach(["참여채팅 목록", "내 게시물 채팅 목록"], id:\.self){ category in
                   Button(action:{
                       if selectedCategory == category{
                           return
                       }
                       selectedCategory = category
                   }){
                       Text(category)
                           .frame(width: 165, height: 50)
                           .foregroundColor(selectedCategory == category ? .white : .black)
                           .background(selectedCategory == category ? Color.blue : Color.clear)
                           .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 1)
                           )
                   }
                   .padding(.horizontal, 15)
               }
           }
           .padding(.top, 10)
           .padding(5)
           
       }
       .padding()
   }
}

struct ChatListMain: View {
   @EnvironmentObject var userManager: UserManager
   @State private var selectedCategory: String
   @State private var chattingRooms: [ChattingRoom] = []
   @State private var postImages: [String: String] = [:] // 게시물 이미지 저장
   @State private var userNames: [String: String] = [:] // 유저 이름 저장
   @State private var lastMessages: [String: String] = [:] // 마지막 메시지 저장
   @State private var posts: [String: String] = [:] // 게시물 정보 저장
   @State private var selectedPostId: String? = nil // 선택한 게시물의 ID
   @State private var expandedPostId: String? = nil // 현재 열려있는 게시물
   @State private var lastMessagesTimestamps: [String: Timestamp] = [:]
    // @State private var unreadMessageCounts: [String: Int] = [:] // 채팅방별 안 읽은 메시지 개수
    
   private var db = Firestore.firestore()
    
    init(selectedCategory: String = "참여채팅 목록", selectedPostId: String? = nil) {
            _selectedCategory = State(initialValue: selectedCategory)
            _expandedPostId = State(initialValue: selectedPostId)
        }

   
   var body: some View {
       VStack{
           chattingCategoryButtonView(selectedCategory: $selectedCategory)
          
           if selectedCategory == "내 게시물 채팅 목록" {
               if posts.isEmpty{
                   VStack {
                       Spacer()
                       Text("현재 참여 채팅목록이 없습니다.")
                           .font(.title2)
                           .foregroundColor(.gray)
                           .padding()
                       Spacer()
                   }
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
               } else{
                   ScrollView {
                       LazyVStack(spacing: 0) {
                           ForEach(chattingRooms.filter { !$0.isGuestLeft }.indices, id: \.self) { index in
                               let room = chattingRooms.filter { !$0.isGuestLeft }[index]
                               
                               NavigationLink(
                                   destination: ChatView(postIdx: room.postIdx, chatRoomId: room.id)
                               ) {
                                   HStack(spacing: 12) {
                                       // 썸네일
                                       if let imageUrl = postImages[room.postIdx], let url = URL(string: imageUrl) {
                                           AsyncImage(url: url) { phase in
                                               switch phase {
                                               case .empty:
                                                   ProgressView()
                                                       .frame(width: 55, height: 55)
                                               case .success(let image):
                                                   image
                                                       .resizable()
                                                       .scaledToFill()
                                                       .frame(width: 55, height: 55)
                                                       .clipShape(RoundedRectangle(cornerRadius: 10))
                                               case .failure:
                                                   Image("NoImage")
                                                       .resizable()
                                                       .scaledToFill()
                                                       .frame(width: 55, height: 55)
                                                       .clipShape(RoundedRectangle(cornerRadius: 10))
                                               @unknown default:
                                                   EmptyView()
                                               }
                                           }
                                       } else {
                                           Image("NoImage")
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: 55, height: 55)
                                               .clipShape(RoundedRectangle(cornerRadius: 10))
                                       }

                                       // 텍스트 정보
                                       VStack(alignment: .leading, spacing: 5) {
                                           HStack{
                                               Text(userNames[room.guestIdx] ?? "이름 불러오기 실패")
                                                   .font(.headline)
                                               
                                               Spacer()
                                               
                                               // 마지막 메시지 시간 표시
                                               if let messageTime = lastMessagesTimestamps[room.id] {
                                                               Text(formatTimestamp(messageTime))
                                                                   .font(.caption)
                                                                   .foregroundColor(.gray)
                                                           }
                                           }

                                           Text(lastMessages[room.id] ?? "")
                                               .font(.subheadline)
                                               .foregroundColor(.gray)
                                               .lineLimit(1)
                                               .truncationMode(.tail)
                                       }

                                       Spacer()
                                   }
                                   .padding(.vertical, 12)
                                   .padding(.horizontal)
                               }

                               if index != chattingRooms.filter { !$0.isGuestLeft }.count - 1 {
                                   Divider()
                                       .padding(.leading, 80) // 이미지 공간만큼 들여쓰기 (선택)
                               }
                           }
                       }
                   }

               }
          }
           else {
               if chattingRooms.isEmpty{
                   VStack {
                       Spacer()
                       Text("현재 게시물에 대한 채팅이 없습니다.")
                           .font(.title2)
                           .foregroundColor(.gray)
                           .padding()
                       Spacer()
                   }
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
               } else {
                   ScrollView {
                       LazyVStack(spacing: 0) {
                           ForEach(chattingRooms.filter { !$0.isGuestLeft }.indices, id: \.self) { index in
                               let room = chattingRooms.filter { !$0.isGuestLeft }[index]
                               
                               NavigationLink(
                                   destination: ChatView(postIdx: room.postIdx, chatRoomId: room.id)
                               ) {
                                   HStack(spacing: 12) {
                                       if let imageUrl = postImages[room.postIdx], let url = URL(string: imageUrl) {
                                           AsyncImage(url: url) { phase in
                                               switch phase {
                                               case .empty:
                                                   ProgressView()
                                                       .frame(width: 55, height: 55)
                                               case .success(let image):
                                                   image
                                                       .resizable()
                                                       .scaledToFill()
                                                       .frame(width: 55, height: 55)
                                                       .clipShape(RoundedRectangle(cornerRadius: 10))
                                               case .failure:
                                                   Image("NoImage")
                                                       .resizable()
                                                       .scaledToFill()
                                                       .frame(width: 55, height: 55)
                                                       .clipShape(RoundedRectangle(cornerRadius: 10))
                                               @unknown default:
                                                   EmptyView()
                                               }
                                           }
                                       } else {
                                           Image("NoImage")
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: 55, height: 55)
                                               .clipShape(RoundedRectangle(cornerRadius: 10))
                                       }

                                       VStack(alignment: .leading, spacing: 5) {
                                           HStack{
                                               Text(userNames[room.hostIdx] ?? "이름 불러오기 실패")
                                                   .font(.headline)
                                               
                                               Spacer()
                                               
                                               // 마지막 메시지 시간 표시
                                               if let messageTime = lastMessagesTimestamps[room.id] {
                                                               Text(formatTimestamp(messageTime))
                                                                   .font(.caption)
                                                                   .foregroundColor(.gray)
                                                           }
                                               
                                           }

                                           Text(lastMessages[room.id] ?? "")
                                               .font(.subheadline)
                                               .foregroundColor(.gray)
                                               .lineLimit(1)
                                               .truncationMode(.tail)
                                       }

                                       Spacer()
                                   }
                                   .padding(.vertical, 12)
                                   .padding(.horizontal)
                               }

                               if index != chattingRooms.filter { !$0.isGuestLeft }.count - 1 {
                                   Divider()
                                       .padding(.leading, 80)
                               }
                           }
                       }
                   }

               }
           }
    }
    .onChange(of: selectedCategory, perform: { _ in
        loadChattingRooms()
    })
    .onAppear {
        loadChattingRooms()
        if selectedCategory == "내 게시물 채팅 목록", let selectedPostId = selectedPostId {
                loadChattingRoomsForPost(postIds: [selectedPostId])
            }
    }
    }
    
    func loadChattingRooms() {
            guard let userId = userManager.userId else {
                print("오류: 로그인된 유저 없음")
                chattingRooms = []
                posts = [:]
                return
            }
            
            if selectedCategory == "참여채팅 목록" {
                db.collection("chattingRooms")
                    .whereField("guest_idx", isEqualTo: userId)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("채팅방 로드 오류: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.chattingRooms = [] // 에러 시 빈 배열로 초기화
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.chattingRooms = snapshot?.documents.compactMap { document in
                                    let data = document.data()
                                    return ChattingRoom(
                                        id: document.documentID,
                                        postIdx: data["post_idx"] as? String ?? "",
                                        hostIdx: data["host_idx"] as? String ?? "",
                                        guestIdx: data["guest_idx"] as? String ?? "",
                                        isHostLeft: data["isHostLeft"] as? Bool ?? false,
                                        isGuestLeft: data["isGuestLeft"] as? Bool ?? false,
                                        roomState: data["roomState"] as? Bool ?? false
                                    )
                                } ?? []
                                self.loadPostImages()
                                self.loadUserNames()
                                self.loadLastMessages()
                                //self.loadUnreadMessageCounts()
                            }
                        }
                    }
            } else if selectedCategory == "내 게시물 채팅 목록" {
                db.collection("posts")
                    .whereField("user_idx", isEqualTo: userId)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("게시물 로드 오류: \(error.localizedDescription)")
                            self.posts = [:]
                            self.chattingRooms = []
                        } else {
                            self.posts = snapshot?.documents.reduce(into: [String: String]()) { result, document in
                                let data = document.data()
                                if let postTitle = data["title"] as? String {
                                    result[document.documentID] = postTitle
                                }
                            } ?? [:]
                            if self.posts.isEmpty {
                                print("현재 사용자의 게시물이 없습니다.")
                                self.chattingRooms = []
                            } else {
                                self.loadChattingRoomsForPost(postIds: Array(self.posts.keys))
                            }
                           // self.loadUnreadMessageCounts()
                        }
                    }
            }
        }
    
    func loadChattingRoomsForPost(postIds: [String]) {
        guard let userId = userManager.userId else { return }
        db.collection("chattingRooms")
            .whereField("post_idx", in: postIds)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("채팅방 로드 오류: \(error.localizedDescription)")
                } else {
                    var filteredPosts: [String: String] = [:]
                    
                    // 모든 채팅방을 로드하여 필터링
                    if let documents = snapshot?.documents {
                        self.chattingRooms = documents.compactMap { document in
                            let data = document.data()
                            return ChattingRoom(
                                id: document.documentID,
                                postIdx: data["post_idx"] as? String ?? "",
                                hostIdx: data["host_idx"] as? String ?? "",
                                guestIdx: data["guest_idx"] as? String ?? "",
                                isHostLeft: data["isHostLeft"] as? Bool ?? false,
                                isGuestLeft: data["isGuestLeft"] as? Bool ?? false,
                                roomState: data["roomState"] as? Bool ?? false
                            )
                        }
                        
                        // 게시물별로 활성화된 채팅방 확인
                        for postId in postIds {
                            let activeRooms = self.chattingRooms.filter { $0.postIdx == postId && !$0.isHostLeft }
                            if !activeRooms.isEmpty {
                                filteredPosts[postId] = self.posts[postId] // 활성화된 채팅방이 있는 게시물만 유지
                            }
                        }
                    }
                    
                    // 필터링된 게시물 목록 업데이트
                    DispatchQueue.main.async {
                        self.posts = filteredPosts
                        self.loadPostImages()
                        self.loadUserNames()
                        self.loadLastMessages()
                    }
                }
            }
    }

   
   func loadPostImages(){
       for room in chattingRooms{
           db.collection("posts").document(room.postIdx).collection("postImages")
               .limit(to: 1)
               .getDocuments{ snapshot, error in
                   if let error = error{
                       print("게시물 이미지 로드 오류: \(error.localizedDescription)")
                   } else {
                       if let document = snapshot?.documents.first,
                          let imageUrl = document["image_url"] as? String {
                           postImages[room.postIdx] = imageUrl
                       }
                   }
               }
       }
   }
   
   func loadUserNames() {
       if selectedCategory == "참여채팅 목록"{
           for room in chattingRooms {
               db.collection("users").document(room.hostIdx).getDocument { document, error in
                   if let error = error {
                       print("유저 이름 로드 오류: \(error.localizedDescription)")
                   } else {
                       if let document = document, document.exists {
                           let data = document.data()
                           let hostName = data?["name"] as? String ?? "이름 없음"
                           userNames[room.hostIdx] = hostName
                       }
                   }
               }
           }
       }
       else if selectedCategory == "내 게시물 채팅 목록"{
           for room in chattingRooms {
               db.collection("users").document(room.guestIdx).getDocument { document, error in
                   if let error = error {
                       print("유저 이름 로드 오류: \(error.localizedDescription)")
                   } else {
                       if let document = document, document.exists {
                           let data = document.data()
                           let guestName = data?["name"] as? String ?? "이름 없음"
                           userNames[room.guestIdx] = guestName
                       }
                   }
               }
           }
       }
   }
   
   func loadLastMessages() {
           for room in chattingRooms {
               db.collection("chattingRooms")
                   .document(room.id)
                   .collection("messages")
                   .order(by: "timestamp", descending: true)
                   .limit(to: 1)
                   .getDocuments { snapshot, error in
                       if let error = error {
                           print("메시지 로드 오류: \(error.localizedDescription)")
                       } else {
                           
                           if let document = snapshot?.documents.first {
                               if let messageText = document["messageText"] as? String {
                                   lastMessages[room.id] = messageText
                               }
                               if let timestamp = document["timestamp"] as? Timestamp {
                                   lastMessagesTimestamps[room.id] = timestamp
                               } else {
                                   print("⚠️ timestamp 없음 in room \(room.id), data: \(document.data())")
                               }
                           }
                           
                       }
                   }
               }
       }
   
   func navigateToChatRoom(postIdx: String, chatRoomId: String) {
           print("Navigating to Chat Room - Post ID: \(postIdx), Chat Room ID: \(chatRoomId)")
       
    }
    
    func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm" // or "HH:mm" for 24시간
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
//    func loadUnreadMessageCounts() {
//        guard let userId = userManager.userId else { return }
//
//        for room in chattingRooms {
//            db.collection("chattingRooms")
//                .document(room.id)
//                .collection("messages")
//                .whereField("isRead", isEqualTo: false)
//                .whereField("senderID", isNotEqualTo: userId) // 내가 보낸 메시지는 제외
//                .getDocuments { snapshot, error in
//                    if let error = error {
//                        print("안 읽은 메시지 개수 로드 오류: \(error.localizedDescription)")
//                    } else {
//                        let unreadCount = snapshot?.documents.count ?? 0
//                        DispatchQueue.main.async {
//                            print("채팅방 \(room.id)의 안 읽은 메시지 개수: \(unreadCount)")
//                            self.unreadMessageCounts[room.id] = unreadCount
//                        }
//                    }
//                }
//        }
//    }

}

#Preview {
   // UserManager 초기화 및 데이터 설정
   let userManager = UserManager()
   userManager.userId = "AddslmGVtbVIIvY62xG0hVIDy462"

   // selectedCategory를 @State로 설정
   return ChatListMain()
       .environmentObject(userManager)
}
