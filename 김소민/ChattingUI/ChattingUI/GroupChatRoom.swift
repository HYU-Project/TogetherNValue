//
//  GroupChatRoom.swift
//  ChattingUI
//
//  Created by somin on 11/10/24.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID() // SwiftUI에서 사용되는 고유 id (데이터베이스와 무관)
    let senderUserIdx: Int // 유저 idx
    let senderName: String // 유저 이름
    let text: String
    let isUserMessage: Bool // 자신이 보낸 메시지인지 여부
    let time: String
}

struct GroupChatRoom: View {
    
    let chatRoomIdx: Int
    let chatRoomName: String
    let postAuthorId: Int // 게시물 작성자 ID
    let currentUserId: Int // 현재 사용자 ID
    
    // 게시물 작성자인지 여부를 확인
    var isPostAuthor: Bool {
        return postAuthorId == currentUserId
    }
    
    // 그룹 채팅방 더미데이터
    @State private var messages: [ChatMessage] = [
        ChatMessage(senderUserIdx: 111, senderName: "Alice", text: "안녕하세요!", isUserMessage: false, time: "10:30 AM"),
        ChatMessage(senderUserIdx: 123, senderName: "Me", text: "안녕하세요!", isUserMessage: true, time: "10:31 AM"),
        ChatMessage(senderUserIdx: 333, senderName: "Bob", text: "혹시 구매 장소 바꿀 수 있을까요?", isUserMessage: false, time: "10:32 AM")
    ]
    
    @State private var newMessage = ""
    
    @State private var showingOptions = false // 옵션 (거래 완료, 채팅방 나가기, 취소)
    
    @State private var showingAlert1 = false // 거래 완료 버튼 클릭시 생기는 알림창
    
    @State private var showingAlert2 = false // 채팅방 나가기 버튼 클릭시 생기는 알림창
   
    @Environment(\.dismiss) private var dismiss // 현재 뷰를 닫기 위한 dismiss 환경 변수
    
    @State private var isChatRoomCompleted = false // 거래 완료시 채팅방 막기
    
    @State private var showImageAndFileOptions = false // + 버튼 클릭시 이미지, 파일 버튼
    
    func leaveChatRoom(){
        // 여기에 네트워크 요청 또는 데이터베이스 작업 추가
        // 예: chat_room_members 테이블에서 현재 유저의 member_idx 삭제
        print("채팅방에서 나감: chat_room_members 테이블에서 해당 유저 삭제")
    }
    
    func completeTransaction() {
        // 데이터베이스에서 채팅방 상태와 게시물 상태를 완료로 업데이트하는 로직 추가
        // 예: 서버에 API 요청을 보내서 채팅방과 게시물의 상태를 완료로 변경
        
        isChatRoomCompleted = true // 채팅방 상태를 완료로 설정
        messages.append(ChatMessage(senderUserIdx: 0, senderName: "System", text: "공지) 거래가 완료되어 채팅방을 더이상 사용하실 수 없습니다.", isUserMessage: false, time: "지금")) // 마지막 시스템 메시지 추가
        }
    
    var body: some View {
        VStack {
            ZStack {
                Text(chatRoomName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showingOptions.toggle()
                    }) {
                        Image("appSetting")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 25, height: 25)
                    }
                    .padding(.trailing, 10) 
                }
                .confirmationDialog("options", isPresented: $showingOptions, titleVisibility: .visible){
                    if isPostAuthor {
                        Button("거래 완료", role: .none) {
                            showingAlert1 = true
                        }
                        .disabled(isChatRoomCompleted) // 거래 완료 시 거래완료 버튼 비활성화
                    }
                        Button("채팅방 나가기", role: .destructive) {
                            showingAlert2 = true
                        }
                        Button("취소", role: .cancel) {
                            // 취소 버튼
                        }
                }
                .alert("거래가 확정하시겠습니까? 확정시, 채팅방을 더이상 사용할 수 없습니다.",isPresented: $showingAlert1){
                    HStack {
                        Button("확인"){
                            completeTransaction()
                            dismiss() // 이전 화면으로 돌아가기
                        }
                        Button("취소"){
                            
                        }
                        
                    }
                }
                .alert("채팅방을 나가시겠습니까?", isPresented: $showingAlert2){
                    HStack {
                        Button("확인"){
                            leaveChatRoom()// 해당 유저를 chat_room_members의 member_idx를 삭제하기 (채팅방 리스트에서 삭제)
                            dismiss() // 이전 화면으로 돌아가기
                        }
                        Button("취소"){
                            
                        }
                    }
                }
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        if message.isUserMessage {
                            HStack {
                                Spacer()
                                ChatBubble(message: message, alignment: .trailing)
                            }
                        } else {
                            HStack {
                                ChatBubble(message: message, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
    
            Divider()
            
            
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation{
                        showImageAndFileOptions.toggle()
                    }
                }){
                    Image(systemName: showImageAndFileOptions ? "xmark" : "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.black)
                }
                TextField("메시지를 입력하세요", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                    .disabled(isChatRoomCompleted) // 거래 완료 시 입력 비활성화
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                .disabled(newMessage.isEmpty) // 메시지가 없을 경우 버튼 비활성화
                .disabled(isChatRoomCompleted) // 거래 완료 시 버튼 비활성화
            }
            .padding()
            
            if showImageAndFileOptions {
                HStack(spacing: 30){
                    Button(action: {
                        
                    }){
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.black)
                            
                    }.padding()
                    
                    Button(action: {
                        
                    }){
                        Image(systemName: "doc")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.black)
                    }
                    .padding()
                }
                .transition(.move(edge: .bottom)) // 슬라이드 애니메이션
                .animation(.easeInOut(duration: 0.05), value: showImageAndFileOptions)
            }
        }
        
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let currentTime = formatter.string(from: Date())
        
        let message = ChatMessage(senderUserIdx: 123, senderName: "Me", text: newMessage, isUserMessage: true, time: currentTime)
        
        messages.append(message)
        newMessage = ""
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let alignment: Alignment
    
    var body: some View {
        VStack(alignment: alignment == .trailing ? .trailing : .leading) {
            if !message.isUserMessage { // 상대방 메시지인 경우
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(message.text)
                .padding()
                .background(message.isUserMessage ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
                .cornerRadius(10)
                .foregroundColor(message.isUserMessage ? .white : .black)
                .frame(maxWidth: 250, alignment: alignment)
            
            Text(message.time)
                .font(.caption2)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
        }
        .padding(alignment == .trailing ? .leading : .trailing, 50)
    }
}


#Preview {
    GroupChatRoom(chatRoomIdx: 1, chatRoomName: "배달 같이 시키실 분?", postAuthorId: 123,currentUserId: 123 )
}
