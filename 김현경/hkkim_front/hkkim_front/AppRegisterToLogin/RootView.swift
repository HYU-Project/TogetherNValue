//회원가입 유무 상태에 따른 화면 변동
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct RootView: View {
    @State private var isLoggedIn: Bool? = nil // 로그인 상태
    @State private var hasSchoolEmail: Bool? = nil // 학교 선택 여부 상태
    
    var body: some View {
        Group {
            if let isLoggedIn = isLoggedIn {
                if isLoggedIn {
                    if let hasSchoolEmail = hasSchoolEmail {
                        if hasSchoolEmail {
                            ContentView()
                        } else {
                            SelectSchoolView()
                        }
                    } else {
                        ProgressView("로딩 중...") // schoolEmail 확인 중
                    }
                } else {
                    LoginView()
                }
            } else {
                ProgressView("로딩 중...") // 로그인 상태를 확인하는 로딩 화면
            }
        }
        .onAppear {
            checkLogInStatus()
        }
    }
    
    private func checkLogInStatus() {
        DispatchQueue.main.async {
            if let currentUser = Auth.auth().currentUser {
                print("로그인된 사용자 UID: \(currentUser.uid)")
                self.isLoggedIn = true
                self.checkSchoolEmail(for: currentUser.uid) // schoolEmail 확인
            } else if let googleUser = GIDSignIn.sharedInstance.currentUser {
                print("Google 로그인 사용자: \(googleUser.profile?.email ?? "알 수 없음")")
                self.isLoggedIn = true
                if let currentUser = Auth.auth().currentUser {
                    self.checkSchoolEmail(for: currentUser.uid)
                }
            } else {
                self.isLoggedIn = false
                print("사용자가 로그인되어 있지 않습니다.")
            }
        }
    }
    
    private func checkSchoolEmail(for userId: String) {
        print("Firestore에서 schoolEmail 확인 시작")
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Firestore에서 사용자 데이터 확인 중 오류 발생: \(error.localizedDescription)")
                self.hasSchoolEmail = false
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                let schoolEmail = data?["schoolEmail"] as? String
                print("schoolEmail 확인 결과: \(schoolEmail ?? "없음")")
                self.hasSchoolEmail = schoolEmail?.isEmpty == false
            } else {
                print("사용자 문서가 Firestore에 존재하지 않습니다.")
                self.hasSchoolEmail = false
            }
        }
    }
}
