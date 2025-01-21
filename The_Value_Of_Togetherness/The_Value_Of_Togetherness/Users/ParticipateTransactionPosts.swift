
import SwiftUI

struct ParticipateTransactionPosts: View {
    @EnvironmentObject var userManager: UserManager
    
    @State private var posts: [ParticiaptePost] = []
    @State private var isLoading = true
    @State private var selectedRoomState: String = "참여중"
    
    private let participatePostService = ParticipatePostService()
    
    private func loadPosts() {
        guard let userId = userManager.userId else {
            print("User ID is nil")
            return
        }
        
        isLoading = true
        participatePostService.fetchParticipatePost(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPosts):
                    self.posts = fetchedPosts
                case .failure(let error):
                    print("Error fetching posts: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }
    
    // 선택한 상태에 따라 필터링된 게시물
    var filteredPosts: [ParticiaptePost] {
        posts.filter { post in
            selectedRoomState.isEmpty ||
            (selectedRoomState == "참여중" ? post.roomState : !post.roomState)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("참여 거래")
                    .font(.title)
                    .bold()
                    .padding()
                    .padding(.bottom, 20)
                
                Divider()
                    .padding(.bottom, 10)
                
                RoomStateFilterView(selectedRoomState: $selectedRoomState, loadPosts: loadPosts)
                    .padding()
                
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                    
                    Spacer()
                } else if filteredPosts.isEmpty {
                    
                    Text("해당 상태의 게시물이 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Spacer()
                } else {
                    ScrollView {
                        VStack {
                            ForEach(filteredPosts) { post in
                                ParticipatePostRow(post: post)
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                loadPosts()
            }
        }
    }
}

struct ParticipatePostRow: View {
    let post: ParticiaptePost

    var body: some View {
        HStack {
            if let postImageUrl = post.postImage_url, !postImageUrl.isEmpty {
                // 로컬 파일 경로 처리
                if postImageUrl.starts(with: "file://"), let url = URL(string: postImageUrl) {
                    let localFileURL = URL(fileURLWithPath: url.path)  // file:// 프로토콜을 처리하는 방식
                    if let uiImage = UIImage(contentsOfFile: localFileURL.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    } else {
                        Image("NoImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                } else if let url = URL(string: postImageUrl) {
                    // URL로 이미지 로드
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 60, height: 60)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        case .failure:
                            Image("NoImage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image("NoImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
            } else {
                // 이미지가 없을 경우
                Image("NoImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(post.roomState ? "참여중" : "참여완료")
                    .font(.subheadline)
                    .foregroundColor(post.roomState ? .blue : .green)
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}


#Preview {
    ParticipateTransactionPosts()
        .environmentObject(UserManager())
}
