//
//  ChatRoomList.swift
//  ChattingUI
//
//  Created by somin on 11/10/24.
//

import SwiftUI
// 채팅방 목록(idx,이름,사진)
struct ChatRoom : Identifiable {
    let id: UUID = UUID()
    let idx: Int // 채팅방 idx
    let name: String
    let photoURL: String
}
struct ChatRoomList: View {
    // 더미 데이터 추가 가능
    @State private var chatRooms: [ChatRoom] = [
        ChatRoom(idx: 1, name: "00 물품 나눔 채팅방", photoURL: "https://example.com/chatroom1.jpg"),
        ChatRoom(idx: 2, name: "배민 같이 시켜 먹으실 분?", photoURL: "https://example.com/chatroom2.jpg"),
       ]
    
    // 특정 채팅방을 삭제하는 함수
       private func leaveChatRoom(_ chatRoom: ChatRoom) {
           chatRooms.removeAll { $0.id == chatRoom.id }
       }
    
    var body: some View {
        NavigationStack{
            HStack {
                Text("채팅")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding()
            
            ScrollView{
                VStack {
                    ForEach(chatRooms){
                        chatRoom in
                        NavigationLink(destination: GroupChatRoom(chatRoomIdx : chatRoom.idx, chatRoomName : chatRoom.name, postAuthorId: 123,currentUserId: 123)){
                            HStack{
                                AsyncImage(url: URL(string: chatRoom.photoURL)){
                                    phase in
                                    switch phase{
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                             .frame(width: 50, height: 50)
                                    case .failure:
                                        Image(systemName: "photo")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                  
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                
                                Text(chatRoom.name)
                                    .font(.headline)
                                    .foregroundColor(Color.black)
                                    .padding(.leading, 10)
                                
                                Spacer()
                            }
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .swipeActions(edge:.trailing){
                                Button(role: .destructive){
                                    leaveChatRoom(chatRoom)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                            
                        }
                        
                        Divider()
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ChatRoomList()
}
