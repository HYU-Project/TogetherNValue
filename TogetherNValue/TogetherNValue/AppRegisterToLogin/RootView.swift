//회원가입 유무 상태에 따른 화면 변동
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase
import FirebaseFirestore

struct RootView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        Group {
            if !userManager.isInitialized {
                ProgressView("로딩 중...") // 초기화 중
            } else if userManager.isLoggedIn {
                if let hasSchoolEmail = userManager.hasSchoolEmail {
                    if hasSchoolEmail {
                        ContentView() // 학교 이메일 설정 완료
                    } else {
                        SelectSchoolView() // 학교 이메일 설정 안 됨
                    }
                } else {
                    ProgressView("학교 이메일 설정 여부 확인 중...") // schoolEmail 확인 중
                }
            } else {
                LoginView() // 로그인되지 않은 상태
            }
        }
        .onAppear {
            if !userManager.isInitialized {
                userManager.initializeUserState()
            }
        }
    }
}
