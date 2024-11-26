
//  ChatView : 채팅방 화면

import SwiftUI

// Message 구조체 정의
struct Message: Identifiable, Codable {
    let id: Int
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
            .onAppear(perform: loadMessages)
            .sheet(isPresented: $isShowingPhotoPicker) {
                ImagePicker(sourceType: isShowingCamera ? .camera : .photoLibrary, selectedImage: $selectedImage)
            }
            .onTapGesture {
                if isSheetPresent{
                    isSheetPresent = false
                }
            }
            if isSheetPresent{
                ZStack{
                    Color(.white)
                    Rectangle()
                        .stroke()
                    VStack {
                        ScrollView{
                            HStack {
                                Image(user1.profileImageURL)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke())
                                Text(user1.userName)
                                Spacer()
                            }
                            HStack {
                                Image(user2.profileImageURL)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke())
                                Text(user2.userName)
                                Spacer()
                            }
                            HStack {
                                Image(user3.profileImageURL)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke())
                                Text(user3.userName)
                                Spacer()
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

    func loadMessages() {
        if let savedData = UserDefaults.standard.data(forKey: "messages_\(chatRoom.id)"),
           let savedMessages = try? JSONDecoder().decode([Message].self, from: savedData) {
            messages = savedMessages
        } else {
            messages = [
                Message(id: 1, text: "안녕하세요", isCurrentUser: false),
                Message(id: 2, text: "안녕하세요!", isCurrentUser: true)
            ]
        }
    }

    func sendMessage() {
        let newMessageObj = Message(id: messages.count + 1, text: newMessage, isCurrentUser: true)
        messages.append(newMessageObj)
        newMessage = ""
        saveMessages()
    }

    func saveMessages() {
        if let encodedData = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encodedData, forKey: "messages_\(chatRoom.id)")
        }
    }
    
    func completeTransaction() {
        viewModel.completeTransaction(for: chatRoom)
    }
    
    func leaveChatRoom() {
        viewModel.leaveChatRoom(chatRoom)
        presentationMode.wrappedValue.dismiss()  // 뷰를 닫고 ChatListView로 돌아감
    }
}

struct CustomSheetView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

#Preview {
    ChatView(chatRoom: ChatRoom(id: 1, imageName: "square", title: "배민 맘스터치", contents: "배달 같이 시켜먹어요", location: "itbit 3층", price: "5,000원", isInProgress: true), viewModel: ChatListViewModel(chatRooms: []))
}

