
//  ChatListMain : 채팅방 메인 화면 (채팅방 리스트)

import SwiftUI
import FirebaseFirestore

class FireStoreManager: ObservableObject {
    @Published var title = []
    @Published var content = []
    @Published var location = []
    
    func initialFetch() async {
        do{
            let db = Firestore.firestore()
            var q1 = try await db.collection("Posts").whereField("userID", isEqualTo: "1TqfbGObHZlH3xEtB2VY").getDocuments()
            for document in q1.documents{
                let data = document.data()
                title.append(data["title"] as? String ?? "")
                content.append(data["postContent"] as? String ?? "")
                location .append(data["location"] as? String ?? "")
                viewModel = ChatListViewModel(chatRooms: [
                    ChatRoom(id: 1, imageName: data["chatRoomImageURL"] as! String, title: data["title"] as! String, contents: data["postContent"] as! String, location: data["location"] as! String, price: "", isInProgress: true)
                ])
            }
        }
        catch{
            print("Error q1")
        }
    }

    init() async {
        await initialFetch()
    }
}

var viewModel = ChatListViewModel(chatRooms: [])

struct ChatListMain: View {
    @StateObject var viewModel = ChatListViewModel(chatRooms: [
        ChatRoom(id: 1, imageName: "square", title: "배민 맘스터치", contents: "배달 같이 시켜먹어요", location: "itbit 3층", price: "5,000원", isInProgress: true)
    ])
    @EnvironmentObject var firestoreManager: FireStoreManager
    
    var body: some View {
        NavigationView{
            VStack {
                HStack{
                    Text("채팅")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                }
                .padding()
                
                List {
                    ForEach(viewModel.chatRooms) { chatRoom in
                        NavigationLink(destination: ChatView(chatRoom: chatRoom, viewModel: viewModel)) {
                            HStack {
                                Image(systemName: chatRoom.imageName)
                                    .resizable()
                                    .frame(width: 70, height: 70)
                                    .padding(.trailing, 10)
                                
                                VStack(alignment: .leading) {
                                    Text(chatRoom.title)
                                        .font(.headline)
                                    
                                    Text(chatRoom.contents)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Text(chatRoom.location)
                                        Spacer()
                                        Text(chatRoom.price)
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                }
                            }
                            .background(chatRoom.isInProgress ? Color.white : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.leaveChatRoom(chatRoom)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.completeTransaction(for: chatRoom)
                            } label: {
                                Label("완료", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding()
        }
    }
}

#Preview {
    ChatListMain()
}
