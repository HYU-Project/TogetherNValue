
//  DetailPost : 공구/나눔 게시글 디테일

import SwiftUI

func getCurrentTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}

struct DetailPost: View {
    var post_idx: Int // 전달받은 post_idx
    
    @State private var post: Post? = nil
    @State private var currentImageIndex: Int = 0 // 이미지 슬라이더의 현재 인덱스
    
    @State private var newComment: String = ""
    @State private var newReply: String = ""
    
    // 더미 데이터 (실제로는 post_idx를 통해 API에서 가져올 수 있음)
    @State var allPosts: [Post] = [
        Post(post_idx: 1, user_idx: 1, post_category: "공구", post_categoryType: "배달", title: "Title 1", post_content: "내용 1", location: "ITBT관", want_num: 5, post_status: "거래중", created_at: "", postImages: [], post_likeCnt: 10, post_commentCnt: 2)
    ]
    
    @State var allPostImages: [PostImage] = [
        PostImage(image_idx: 1, post_idx: 1, image_url: "https://via.placeholder.com/150"),
        PostImage(image_idx: 2, post_idx: 1, image_url: "https://via.placeholder.com/150")
    ]
        
    @State var allUsers: [Users] = [
        Users(user_idx: 1, userName: "홍길동", user_phoneNum: "010-1234-5678", school_idx: 1, user_schoolEmail: "", profile_image_url: "https://via.placeholder.com/150", created_at: "")
    ]
    
    @State var allComments: [Comment] = [
        Comment(comment_idx: 1, user_idx: 1, post_idx: 1, comment_content: "이 거래는 정말 좋은 것 같아요!", comment_created_at: "2024-11-16", replies: []),
        Comment(comment_idx: 2, user_idx: 2, post_idx: 1, comment_content: "저도 참여하고 싶어요!", comment_created_at: "2024-11-16", replies: []),
        Comment(comment_idx: 3, user_idx: 3, post_idx: 1, comment_content: "어디서 만나나요?", comment_created_at: "2024-11-16", replies: [])
        ]
    
    // 게시물에 맞는 데이터 찾기
    private var postDetails: Post? {
        allPosts.first { $0.post_idx == post_idx }
    }
    
    private var postImages: [PostImage] {
        return allPostImages
    }
    
    private var user: Users {
        return allUsers.first!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading) {
                    // 작성자 정보 (프로필 사진 및 아이디)
                    HStack {
                        if let profileURL = user.profile_image_url, let url = URL(string: profileURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                case .failure:
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                @unknown default:
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                }
                            }
                        }
                        
                        Text(user.userName) // 작성자 이름
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    // 게시글 제목
                    if postDetails != nil {
                        Text(postDetails?.title ?? "제목 없음")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 25)
                            .padding(.bottom, 5)
                    }
                    
                    // 이미지 슬라이더
                    // (수정 필요)이미지가 없으면 기본 이미지가 아닌 다른 정보만 제공하도록
                    if !postImages.isEmpty {
                        TabView(selection: $currentImageIndex) {
                            ForEach(postImages.indices, id: \.self) { index in
                                AsyncImage(url: URL(string: postImages[index].image_url)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .clipped()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .clipped()
                                    @unknown default:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .clipped()
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(height: 200)
                        .tabViewStyle(PageTabViewStyle())
                    }
                    
                    // 장소와 인원 정보
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("장소: \(postDetails?.location ?? "장소 미정")")
                            }
                            .padding(.top, 8)
                            
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("인원수: \(postDetails?.want_num ?? 0)명")
                            }
                            .padding(.top, 4)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    
                    // 게시글 내용
                    if let postContent = postDetails?.post_content{
                        Text(postContent)
                            .frame(width: 350, height: 200)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding()
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // 참여하기 버튼 액션
                        }) {
                            Text("참여하기")
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.trailing, 1)
                }
                .padding()
                
                Divider()
                
                Text("여기에 광고 배너 들어가기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // 댓글 영역
                VStack(alignment: .leading) {
                    Text("댓글")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    ForEach(allComments) { comment in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("작성자: \(comment.user_idx)") // 작성자 ID로 표시 (실제로는 사용자 이름으로 변경 필요)
                                    .font(.subheadline)
                                    .bold()
                                
                                Spacer()
                                
                                if comment.user_idx == user.user_idx {
                                    Button("수정") {
                                        // 댓글 수정 로직
                                    }
                                    .padding(.trailing, 4)
                                    .foregroundColor(Color.blue)
                                    
                                    Button("삭제") {
                                        deleteComment(comment: comment)
                                    }
                                    .foregroundColor(Color.red)
                                }
                            }
                            
                            Text(comment.comment_content)
                                .font(.body)
                                .padding(.top, 2)
                            
                            Text("작성일: \(comment.comment_created_at)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                            
                            // 대댓글 리스트
                            ForEach(comment.replies) { reply in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("대댓글 작성자: \(reply.user_idx)")
                                            .font(.subheadline)
                                        Spacer()
                                        if reply.user_idx == user.user_idx {
                                            Button("수정") {
                                // 대댓글 수정 로직
                                            }
                                            .padding(.trailing, 4)
                                            Button("삭제") {
                                                deleteReply(reply: reply, in: comment)
                                            }
                                        }
                                    }
                                    Text(reply.reply_content)
                                        .font(.body)
                                        .padding(.leading, 16)
                                }
                            }
                            
                            // 대댓글 작성 필드
                            // (수정 필요!)필드가 각 댓글마다 생겨서 입력했을 때 다른 댓글의 필드에도 값이 입력되는 것처럼 보임
                            HStack {
                                TextField("대댓글을 입력하세요", text: $newReply)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("작성") {
                                    addReply(to: comment)
                                }
                                .padding()
                                .foregroundColor(Color.black)
                            }
                            .padding(.leading, 16)
                        }
                        .padding(.bottom, 8)
                        Divider()
                    }
                    
                    // 댓글 작성 필드
                    HStack {
                        TextField("댓글을 입력하세요", text: $newComment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("댓글 작성") {
                            addComment()
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .padding()
                
    }
    
    func addComment() {
        guard !newComment.isEmpty else { return }
        let comment = Comment(
            comment_idx: allComments.count + 1,
            user_idx: user.user_idx,
            post_idx: post_idx,
            comment_content: newComment,
            comment_created_at: getCurrentTime(),
            replies: []
        )
        allComments.append(comment)
        newComment = ""
    }
    
    func deleteComment(comment: Comment) {
        allComments.removeAll { $0.comment_idx == comment.comment_idx }
    }
    
    func addReply(to comment: Comment) {
        guard !newReply.isEmpty else { return }
        if let index = allComments.firstIndex(where: { $0.comment_idx == comment.comment_idx }) {
            let reply = Reply(
                reply_idx: (allComments[index].replies.last?.reply_idx ?? 0) + 1,
                user_idx: user.user_idx,
                reply_content: newReply,
                reply_created_at: getCurrentTime()
            )
            allComments[index].replies.append(reply)
            newReply = ""
        }
    }
    
    func deleteReply(reply: Reply, in comment: Comment) {
        if let index = allComments.firstIndex(where: { $0.comment_idx == comment.comment_idx }) {
            allComments[index].replies.removeAll { $0.reply_idx == reply.reply_idx }
        }
    }
}

struct DetailPost_Previews: PreviewProvider {
    static var previews: some View {
        DetailPost(post_idx: 1)
    }
}
