// 로그인한 사용자 정보

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class UserManager: ObservableObject {
    @Published var userId: String? = nil
    @Published var isLoggedIn: Bool = false
    @Published var hasSchoolEmail: Bool? = nil
    @Published var isCheckingStatus: Bool = true // 상태 확인 중 여부
    @Published var isInitialized = false

    init() {
        addAuthListener()
    }

    private func addAuthListener() {
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.userId = user?.uid
                self.isLoggedIn = user != nil
                if let uid = user?.uid {
                    self.checkSchoolEmail(for: uid)
                } else {
                    self.isCheckingStatus = false
                }
            }
        }
    }
    
    private func handleAuthStateChange(user: User?) {
        if let user = user {
            self.userId = user.uid
            self.isLoggedIn = true
            self.isInitialized = false // 초기화 필요
            self.checkSchoolEmail(for: user.uid)
        } else {
            self.resetState()
        }
    }

    func initializeUserState() {
        guard !isInitialized else { return } // 이미 초기화되었으면 실행하지 않음
        isCheckingStatus = true
        if let currentUser = Auth.auth().currentUser {
            handleAuthStateChange(user: currentUser)
        } else {
            resetState()
        }
    }
    
    private func resetState() {
            self.userId = nil
            self.isLoggedIn = false
            self.hasSchoolEmail = nil
            self.isInitialized = true
            self.isCheckingStatus = false
        }


    private func checkSchoolEmail(for userId: String) {
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { [weak self] document, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let error = error {
                        print("학교 이메일 확인 중 오류: \(error.localizedDescription)")
                        self.hasSchoolEmail = false
                    } else if let document = document, document.exists,
                              let schoolEmail = document.data()?["schoolEmail"] as? String {
                        self.hasSchoolEmail = !schoolEmail.isEmpty
                    } else {
                        self.hasSchoolEmail = false
                    }
                    self.isInitialized = true // 초기화 완료
                    self.isCheckingStatus = false
                }
            }
        }

    func logOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.resetState() // 상태 초기화
            }
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







