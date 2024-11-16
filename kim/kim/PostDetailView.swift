//포스트 디테일

import SwiftUI

struct PostDetailView: View {
    @State private var isParticipated = false
    @State private var isAuthor = false // 작성자 여부 확인
    @State private var currentImageIndex = 0 // 이미지 슬라이더 인덱스
    let images = ["1", "2", "3"] // 이미지 배열
    @State private var comments = [
        Comment(id: 1, user: "user2", text: "한명이 두개 사도되나요??", replies: []),
        Comment(id: 2, user: "user3", text: "오 너무 이쁘네요!", replies: [])
    ]
    @State private var newComment = ""
    var post: Post
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading) {
                    // 작성자 정보 (프로필 사진 및 아이디)
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        Text(post.user_idx) // 작성자 아이디
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    // 게시글 제목
                    Text(post.title)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 25)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 4)
                        )
                        .padding(.bottom, 5)
                    
                    VStack {
////                         이미지 슬라이더
//                        TabView(selection: $currentImageIndex) {
//                            ForEach(images.indices, id: \.self) { index in
//                                Image(images[index])
//                                    .resizable()
//                                    .scaledToFill()
//                                    .tag(index)
//                                    .frame(height: 100)
//                                    .clipped()
//                            }
//                        }
//                        .padding()
//                        .frame(width: 350, height: 100)
//                        .overlay(
//                            Rectangle()
//                                .stroke(Color.black, lineWidth: 2)
//                        )
//                        .tabViewStyle(PageTabViewStyle())
                        
                        TabView{
                            Image(post.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .clipped()
                        }
                        .padding()
                        .frame(width: 350, height: 100)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        // 장소와 인원 정보
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text(post.location)
                                }
                                .padding(.top, 8)
                                
                                HStack {
                                    Image(systemName: "person.2.fill")
                                    Text("인원수: \(post.want_num)명")
                                }
                                .padding(.top, 4)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        
                        // 자세한 글 내용
                        Text(post.post_content)
                            .padding()
                            .frame(width: 350, height: 250)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        
                        // 참여하기 버튼을 글 내용 밑에 배치하고 오른쪽 정렬
                        HStack {
                            Spacer()
                            Button(action: {
                                isParticipated.toggle()
                            }) {
                                Text(isParticipated ? "참여완료" : "참여하기")
                                    .padding()
                                    .background(isParticipated ? Color.gray : Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.trailing, 1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 4)
                    ) // 전체 VStack을 박스 형태로 만듦
                    
                    Divider()
                    
                    // 댓글 영역
                    VStack(alignment: .leading) {
                        Text("댓글")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        ForEach(comments) { comment in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(comment.user)
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    if comment.user == "user1" { // 자신이 쓴 댓글만 수정/삭제 가능
                                        Button(action: {
                                            // 댓글 수정 로직
                                        }) {
                                            Text("수정")
                                        }
                                        Button(action: {
                                            // 댓글 삭제 로직
                                        }) {
                                            Text("삭제")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                
                                Text(comment.text)
                                    .padding(.vertical, 4)
                                
                                // 대댓글 표시
                                ForEach(comment.replies) { reply in
                                    HStack {
                                        Text("↳ \(reply.user)")
                                            .font(.subheadline)
                                            .bold()
                                        Text(reply.text)
                                            .font(.subheadline)
                                            .padding(.leading, 8)
                                        Spacer()
                                    }
                                }
                                
                                // 대댓글 작성
                                if comment.user == "user1" || isAuthor {
                                    TextField("대댓글 작성...", text: $newComment, onCommit: {
                                        addReply(to: comment)
                                    })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            
            // 항상 하단에 고정된 새로운 댓글 작성 영역
            HStack {
                TextField("댓글을 입력하세요...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addComment) {
                    Text("보내기")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    func addComment() {
        let comment = Comment(id: comments.count + 1, user: "user1", text: newComment, replies: [])
        comments.append(comment)
        newComment = ""
    }
    
    func addReply(to comment: Comment) {
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[index].replies.append(Comment(id: comments[index].replies.count + 1, user: "user1", text: newComment, replies: []))
            newComment = ""
        }
    }
}

// 댓글 모델
struct Comment: Identifiable {
    let id: Int
    let user: String
    let text: String
    var replies: [Comment]
}

// 미리보기
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
