import SwiftUI
import FirebaseFirestore

class FireStoreManager: ObservableObject {
    @Published var title: [String] = []
    @Published var content: [String] = []
    @Published var location: [String] = []
    
    func initialFetch() async {
        print("Starting Firestore query...")
        do {
            let q1 = try await db.collection("Posts").whereField("userID", isEqualTo: "1TqfbGObHZlH3xEtB2VY").getDocuments()
            print("Firestore query completed. Documents fetched: \(q1.documents.count)")
            
            for document in q1.documents {
                let data = document.data()
                print("Fetched document data: \(data)")
                
                // Ensuring UI updates happen on the main thread
                DispatchQueue.main.async {
                    self.title.append(data["title"] as? String ?? "")
                    self.content.append(data["postContent"] as? String ?? "")
                    self.location.append(data["location"] as? String ?? "")
                    
                    // Create the chat room model object and update the view model
                    let newChatRoom = ChatRoom(
                        id: document.documentID, // Adjust this if you want to use unique ID
                        imageName: data["chatRoomImageURL"] as! String,
                        title: data["title"] as! String,
                        contents: data["postContent"] as! String,
                        location: data["location"] as! String,
                        price: "",
                        isInProgress: true
                    )
                    
                    viewModel.chatRooms.append(newChatRoom)
                    print("Added chat room: \(newChatRoom)")
                }
            }
        } catch {
            print("Error fetching Firestore documents: \(error.localizedDescription)")
        }
    }

    init() {
        Task {
            await initialFetch()
        }
    }
}
let db = Firestore.firestore()
var viewModel = ChatListViewModel(chatRooms: [])

struct ChatListMain: View {

    @EnvironmentObject var firestoreManager: FireStoreManager
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
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
