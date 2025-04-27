import SwiftUI
import FirebaseFirestore

struct ParticipateTransactionPosts: View {
    @EnvironmentObject var userManager: UserManager
    @State private var participatedPosts: [ParticiaptePost] = []
    @State private var isLoading = true
    
    private var db = Firestore.firestore()
    private let participatePostService = ParticipatePostService()

    var body: some View {
        NavigationView {
            VStack {
                
                Text("내가 참여한 거래")
                    .font(.title)
                    .bold()
                    .padding()
                    .padding(.bottom, 10)
                
                Divider()
                    .padding(.bottom, 10)
                
                if isLoading {
                    Spacer()
                    ProgressView("로딩 중...")
                        .padding()
                    Spacer()
                } else if participatedPosts.isEmpty {
                    Spacer()
                    Text("참여한 거래가 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    ScrollView{
                        VStack(spacing: 5){
                            ForEach(participatedPosts){ post in
                                NavigationLink(destination: DetailPost(post_idx: post.post_idx)) {
                                    ParticipatedPostRow(post: post)
                                        .padding(5)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
        .onAppear {
            fetchParticipatedPosts()
        }
    }
    
    private func fetchParticipatedPosts() {
        guard let userId = userManager.userId else {
            print("유저 ID 없음")
            self.isLoading = false
            return
        }

        self.isLoading = true

        participatePostService.fetchParticipatePost(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.participatedPosts = posts
                    print("참여한 거래 불러옴: \(posts.count) 개")
                case .failure(let error):
                    print("참여한 거래 불러오기 실패: \(error.localizedDescription)")
                    self.participatedPosts = []
                }
                self.isLoading = false
            }
        }
    }

    
}


#Preview {
    ParticipateTransactionPosts()
        .environmentObject(UserManager())
}
