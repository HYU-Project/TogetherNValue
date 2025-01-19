//  GroupPurchaseMain : 공구 메인 화면

import SwiftUI
import FirebaseFirestore

struct GroupPurchaseMain: View {
    @EnvironmentObject var userManager: UserManager
    @ObservedObject var viewModel: GroupPurchaseViewModel
    
    @State private var schoolIdx: String? = nil
    @State private var schoolName: String? = nil
    @State private var selectedCategory: String = ""
    @State private var searchText: String = ""
    @State private var showCreatePostView = false
    @State private var posts: [PurchasePost] = []
    
    let db = Firestore.firestore()
    
    private let firestoreService = PurchaseFirestoreService() // 객체 선언

    private func checkAndUpdatePostStatus(for post: PurchasePost) {
        firestoreService.fetchActiveChatRoomCount(for: post.post_idx) { activeChatRoomCount in
            if post.want_num == activeChatRoomCount {
                firestoreService.updatePostStatus(postIdx: post.post_idx, newStatus: "거래완료") { success in
                    if success {
                        DispatchQueue.main.async {
                            if let index = self.posts.firstIndex(where: { $0.post_idx == post.post_idx }) {
                                self.posts[index].post_status = "거래완료"
                            }
                        }
                    }
                }
            }
        }
    }

    var filteredPosts: [PurchasePost] {
        viewModel.posts.filter { post in
            (selectedCategory.isEmpty || post.post_categoryType == selectedCategory) &&
            (searchText.isEmpty || post.title.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Text("공구")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    if let schoolName = viewModel.schoolName {
                        HeaderView(schoolName: schoolName)
                    }
                    Text("여기에 광고 배너 들어가기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    CategoryButtonsView(selectedCategory: $selectedCategory)
                    SearchBarView(searchText: $searchText)
                    PurchasePostListView(posts: posts, filteredPosts: filteredPosts)
                    
                }
                .padding()
                .onAppear {
                    if let userId = userManager.userId {
                        viewModel.fetchSchoolName(userId: userId)
                        viewModel.loadPosts() // 초기 로드
                    } else {
                        print("로그인된 유저가 없습니다.") // 로그인되지 않았을 경우 처리
                    }
                }
                
                FloatingActionButton(showCreatePostView: $showCreatePostView)
            }
        }
    }
}

