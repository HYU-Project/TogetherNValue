// 로그인한 사용자 정보

import FirebaseAuth
import FirebaseFirestore

class UserManager: ObservableObject {
    @Published var userId: String? = nil
    
    init() {
        // 앱 시작 시 currentUser를 확인하여 로그인된 유저 정보를 가져옵니다.
        self.userId = Auth.auth().currentUser?.uid
    }
    
    // 로그인 상태가 변경될 때마다 갱신할 수 있도록 refresh 함수 추가
    func refreshUserId() {
        self.userId = Auth.auth().currentUser?.uid
    }
}




