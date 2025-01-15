// 로그인한 사용자 정보

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class UserManager: ObservableObject {
    @Published var userId: String? = nil
    
    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.userId = user?.uid
        }
    }
    
    // 로그아웃 처리
    func logOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut() // 구글 세션 로그아웃
            self.userId = nil // 상태 초기화
        } catch let error {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    // 로그인 상태가 변경될 때마다 자동으로 갱신되므로 refreshUserId()를 따로 호출할 필요 없음
    // 만약 필요하다면 해당 함수를 호출하여 명시적으로 상태를 갱신할 수 있음
    func refreshUserId() {
        if let currentUser = Auth.auth().currentUser {
            self.userId = currentUser.uid
        } else {
            self.userId = nil
        }
    }
}






