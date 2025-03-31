//  GroupSharingMain : 나눔 메인 화면

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GroupSharingMain: View {
    @EnvironmentObject var userManager: UserManager
    @State private var schoolIdx: String? = nil
    @State private var schoolName: String? = nil
    @State private var selectedCategory: String = "" // 선택된 카테고리
    @State private var searchText: String = "" // 검색어
    @State private var showCreatePostView = false
    @State private var posts: [SharingPost] = []
    
    let db = Firestore.firestore()

    // schoolName과 schoolIdx를 가져오는 함수
    func fetchSchoolName() {
        guard let currentUserId = userManager.userId else {
            print("로그인한 유저가 없습니다.")
            return
        }
        
        db.collection("users").document(currentUserId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let schoolIdx = data?["school_idx"] as? String {
                    // school_idx를 통해 Schools 컬렉션에서 schoolName 가져오기
                    self.db.collection("schools").document(schoolIdx).getDocument { schoolDocument, error in
                        if let schoolDocument = schoolDocument, schoolDocument.exists {
                            let schoolData = schoolDocument.data()
                            if let schoolName = schoolData?["schoolName"] as? String {
                                // schoolIdx와 schoolName을 @State 변수에 저장
                                self.schoolIdx = schoolIdx
                                self.schoolName = schoolName
                                self.loadPosts() // schoolIdx를 사용하여 게시글을 로드
                            } else {
                                print("schoolName을 찾을 수 없습니다.")
                            }
                        } else {
                            print("Schools 문서를 찾을 수 없습니다.")
                        }
                    }
                } else {
                    print("school_idx를 찾을 수 없습니다.")
                }
            } else {
                print("Users 문서를 찾을 수 없습니다.")
            }
        }
    }
    
    
    private let firestoreService = SharingFirestoreService()
    
    // 게시물 로드
    func loadPosts() {
        guard let schoolIdx = schoolIdx else {
                print("schoolIdx가 없습니다.")
                return
            }
        firestoreService.loadPosts(school_idx: schoolIdx, category: "나눔") { posts in
            self.posts = posts
        }
        
        // 게시물 상태 업데이트 확인
        posts.forEach { post in
            self.checkAndUpdatePostStatus(for: post)
        }
    }
    
    private func checkAndUpdatePostStatus(for post: SharingPost) {
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
    
    // 필터링된 게시물 리스트
    var filteredPosts: [SharingPost] {
        posts.filter { post in
            // 선택된 카테고리와 검색어 조건 적용
            (selectedCategory.isEmpty || post.post_categoryType == selectedCategory) &&
            (searchText.isEmpty || post.title.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    
                    HStack {
                        Text("나눔")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    .padding()
                    
                    if let schoolName = schoolName {
                        HeaderView(schoolName: schoolName)
                    }
                    
                    Text("오늘도 나누는 기쁨, 함께 나눠요.")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundStyle(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    CategoryButtonsView(selectedCategory: $selectedCategory)
                    SearchBarView(searchText: $searchText)
                    SharingPostListView(posts: posts, filteredPosts: filteredPosts)
                }
                .padding()
                .onAppear {
                    if userManager.userId != nil {
                        fetchSchoolName() // userId가 유효할 때만 호출
                        loadPosts()
                    } else {
                        print("로그인된 유저가 없습니다.") // 로그인되지 않았을 경우 처리
                    }
                }
                
                FloatingActionButton(showCreatePostView: $showCreatePostView)
            }
            
        }
    }
}

#Preview {
    GroupSharingMain()
        .environmentObject(UserManager())
}

