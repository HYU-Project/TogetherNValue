
//  ChatRoomManagement 

import SwiftUI
import Combine

// ChatRoom 모델 정의
struct ChatRoom: Identifiable, Codable {
    let id: Int
    let imageName: String
    let title: String
    let contents: String
    let location: String
    let price: String
    var isInProgress: Bool
}

// ChatListViewModel 정의
class ChatListViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoom]
    
    init(chatRooms: [ChatRoom]) {
        self.chatRooms = chatRooms
    }
    
    func completeTransaction(for chatRoom: ChatRoom) {
        if let index = chatRooms.firstIndex(where: { $0.id == chatRoom.id }) {
            chatRooms[index].isInProgress = false
        }
    }
    
    func leaveChatRoom(_ chatRoom: ChatRoom) {
        chatRooms.removeAll { $0.id == chatRoom.id }
    }
}

