//3. 채팅방 리스트 페이지
import SwiftUI

struct ChatListView: View {
    @StateObject var viewModel = ChatListViewModel(chatRooms: [
        ChatRoom(id: 1, imageName: "square", title: "배민 맘스터치", contents: "배달 같이 시켜먹어요", location: "itbit 3층", price: "5,000원", isInProgress: true),
        ChatRoom(id: 2, imageName: "square", title: "슬리퍼 나눔", contents: "한번도 안신은 슬리퍼 나눔해요!", location: "생과대", price: "무료", isInProgress: false)
    ])
    
    var body: some View {
        VStack {
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
        .padding(.horizontal)
        .navigationTitle("참여중인 채팅목록")
    }
}

#Preview {
    ChatListView()
}


