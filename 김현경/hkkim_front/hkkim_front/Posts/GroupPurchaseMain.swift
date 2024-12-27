//  GroupPurchaseMain : 공구 메인 화면

import SwiftUI
import FirebaseFirestore

// TODO: 로그인한 유저와 학교 정보 가져오기
// TODO: Posts table & PostImages & storage(제외) & PostLike & Comment table에서 category = "공구"인 게시글 정보 가져오기 (단, 유저의 학교에 관련한 게시글만 뽑아서 가져와야함)

struct GroupPurchaseMain: View {
    @EnvironmentObject var userManager: UserManager
    @State private var schoolIdx: String? = nil
    @State private var schoolName: String? = nil
    @State private var selectedCategory: String = ""
    @State private var searchText: String = ""
    @State private var showCreatePostView = false
    @State private var posts: [PurchasePost] = []
    
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
                print("users 문서를 찾을 수 없습니다.")
            }
        }
    }
    
    private let firestoreService = PurchaseFirestoreService() // 객체 선언

    // 로그인한 유저의 학교애 관련된 게시글이면서 category = 공구인 게시글 뽑아야함
    func loadPosts(){
        guard let schoolIdx = schoolIdx else {
                print("schoolIdx가 없습니다.")
                return
            }
        firestoreService.loadPosts(school_idx: schoolIdx, category: "공구"){ posts in
            self.posts = posts
        }
    }

    var filteredPosts: [PurchasePost] {
        posts.filter { post in
            (selectedCategory.isEmpty || post.post_categoryType == selectedCategory) &&
            (searchText.isEmpty || post.title.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationView {
            
            ZStack {
                VStack {
                    //Text("Hello, \(userManager.userId ?? "Guest")") // 테스트용
                    
                    if let schoolName = schoolName {
                        HeaderView(category: "공구", schoolName: schoolName)
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
                    if userManager.userId != nil {
                        fetchSchoolName() // userId가 유효할 때만 호출
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
    GroupPurchaseMain()
        .environmentObject(UserManager())
}

