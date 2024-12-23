//  ChatView : 채팅방 화면

import SwiftUI
import FirebaseFirestore

// Message 구조체 정의
struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let isCurrentUser: Bool
}

struct ChatView: View {
    let chatRoom: ChatRoom
    @ObservedObject var viewModel: ChatListViewModel
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @State private var isShowingPhotoOptions = false
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCamera = false
    @State private var isShowingActionSheet = false
    @State private var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode  // presentationMode를 통해 뷰를 닫기 위함
    @State private var isSheetPresent = false
    @State private var usersInChatRoom: [QueryDocumentSnapshot] = []

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: chatRoom.imageName)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .padding(.trailing, 10)
                    VStack(alignment: .leading) {
                        Text(chatRoom.title)
                            .font(.headline)
                        Text(chatRoom.location)
                        Text(chatRoom.price)
                    }
                    
                    Spacer()
                    Button(action:{
                        isSheetPresent.toggle()
                        let db = Firestore.firestore()
                        db.collection("Posts").document(chatRoom.id).collection("Participations").getDocuments { snapshot, error in
                            if let error = error {
                                print("Error fetching participations: \(error)")
                                return
                            }

                            if let documents = snapshot?.documents {
                                self.usersInChatRoom = documents
                            }
                        }

                    }){
                        Image(systemName: "ellipsis.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    ForEach(messages) { message in
                        HStack {
                            if message.isCurrentUser {
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
            .sheet(isPresented: $isShowingPhotoPicker) {
                ImagePicker(sourceType: isShowingCamera ? .camera : .photoLibrary, selectedImage: $selectedImage)
            }
            .onTapGesture {
                if isSheetPresent{
                    isSheetPresent = false
                }
            }
            .onAppear{
                Task {
                    await loadMessages()
                }
            }
            if isSheetPresent{
                ZStack{
                    Color(.white)
                    Rectangle()
                        .stroke()
                    VStack {
                        ScrollView {
                            HStack{
                                Image(systemName: "person.circle")
                                    .frame(width: 30, height: 30)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke())
                                Text("김소민")
                                Spacer()
                            }
                            ForEach(usersInChatRoom, id: \.documentID) { userDocument in
                                if userDocument.documentID.count <= 20 {
                                    UserRowView(userDocument: userDocument)
                                }
                            }
                        }
                        .font(.title)
                        Spacer()
                        HStack {
                            Button(action:{
                                completeTransaction()
                            }){
                                Text("fin")
                                    .foregroundStyle(.blue)
                            }
                            Spacer()
                            Button(action:{
                                leaveChatRoom()
                            }){
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundStyle(.red)
                            }
                        }
                        .font(.title)
                    }
                }
                .frame(width: UIScreen.main.bounds.width*0.7)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    func loadMessages() async {
        do {
            let documents = try await db.collection("ChatMessages")
                .whereField("postID", isEqualTo: chatRoom.id)
                .order(by: "sendAt")
                .getDocuments()
            
            messages = []
            
            // Loop through the documents array
            for document in documents.documents {
                messages.append(
                    Message(
                        id: document.documentID,
                        text: document.data()["messageContent"] as? String ?? "",
                        isCurrentUser: document.data()["senderID"] as? String == "1TqfbGObHZlH3xEtB2VY"
                    )
                )
            }
        } catch {
            print("Error loading messages: \(error)")
        }
    }


    func sendMessage() {
            let newMessageObj = Message(id: UUID().uuidString, text: newMessage, isCurrentUser: true)
            messages.append(newMessageObj)
            newMessage = ""
            saveMessageToFirestore(message: newMessageObj)
        }

    func saveMessageToFirestore(message: Message) {
        let db = Firestore.firestore()
        
        // Format the current timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let formattedTimestamp = formatter.string(from: Date())
        
        db.collection("ChatMessages").addDocument(data: [
            "messageContent": message.text,
            "senderID": "1TqfbGObHZlH3xEtB2VY",
            "sendAt": formattedTimestamp ,// Save the formatted timestamp as a string,
            "postID": chatRoom.id
        ]) { error in
            if let error = error {
                print("Error saving message to Firestore: \(error)")
            } else {
                print("Message saved successfully!")
            }
        }
    }

    
    func completeTransaction() {
        viewModel.completeTransaction(for: chatRoom)
    }
    
    func leaveChatRoom() {
        viewModel.leaveChatRoom(chatRoom)
        db.collection("Posts").document(chatRoom.id).updateData(["userID": "1TqfbGObHZlH3xEtB2VY*"])
        presentationMode.wrappedValue.dismiss()  // 뷰를 닫고 ChatListView로 돌아감
    }
}

struct CustomSheetView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

struct UserRowView: View {
    let userDocument: QueryDocumentSnapshot
    @State private var userData: [String: Any]?
    @State private var isLoading = true
    
    var body: some View {
        HStack {
            if let userData = userData {
                Image(systemName: userData["profileImageURL"] as? String ?? "person.circle")
                    .frame(width: 30, height: 30)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke())
                
                Text(userData["userName"] as? String ?? "Unknown User")
                Spacer()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        let db = Firestore.firestore()
        db.collection("Users").document(userDocument.documentID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, let data = snapshot.data() {
                self.userData = data
            }
        }
    }
}
