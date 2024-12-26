import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct SettingView: View {
    @State private var isPushNotificationEnabled: Bool = true
    @State private var showAlert = false // 팝업 표시 여부
    @State private var alertTitle = "" // 팝업 제목
    @State private var alertMessage = "" // 팝업 메시지
    @State private var isLogout = false // 로그인 화면으로 이동 여부
    @State private var isShowingPasswordSheet = false // 비밀번호 입력 Sheet 표시
    @State private var passwordInput = "" // 탈퇴 시 비밀번호 입력

    var body: some View {
        NavigationView {
            List {
                // 사용자 계정 관리 섹션
                Section(header: Text("사용자 계정 관리")) {
                   // NavigationLink(destination: UserInfoSettingsView()) {
                        Text("사용자 정보 관리")
                    //}
                }

                // 알림 설정 섹션
                Section(header: Text("알림 설정")) {
                    Toggle("푸시 알림", isOn: $isPushNotificationEnabled)
                        .onChange(of: isPushNotificationEnabled) { newValue in
                            print("푸시 알림 설정 변경됨: \(newValue)")
                        }
                }

                // 지원 및 도움말 섹션
                Section(header: Text("지원 및 도움말")) {
                    //NavigationLink(destination: ContactSupportView()) {
                        Text("문의하기")
                    //}
                }

                // 기타 섹션
                Section(header: Text("기타")) {
                    //NavigationLink(destination: NoticesView()) {
                        Text("공지사항")
                    //}
                   
                    //NavigationLink(destination: TermsOfServiceView()) {
                        Text("이용약관")
                    //}
                    Text("앱 버전: \(getAppVersion())")
                        .foregroundColor(.gray)

                    // 로그아웃 버튼
                    Button(action: {
                        logOut()
                    }) {
                        Text("로그아웃")
                            .foregroundColor(.red)
                    }

                    // 탈퇴하기 버튼
                    Button(action: {
                        checkUserProviderAndDelete()
                    }) {
                        Text("탈퇴하기")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("환경설정")
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertTitle, isPresented: $showAlert, actions: {
                Button("확인") {
                    if alertTitle == "탈퇴 완료" || alertTitle == "로그아웃 완료" {
                        closePopupAndNavigate()
                    }
                }
            }, message: {
                Text(alertMessage)
            })
            .fullScreenCover(isPresented: $isLogout) {
                NavigationView {
                    LoginView() // 로그인 화면으로 이동
                }
            }
        }
    }

    // 앱 버전 가져오기
    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // 로그아웃 로직
    func logOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut() // 구글 세션도 로그아웃
            alertTitle = "로그아웃 완료"
            alertMessage = "성공적으로 로그아웃되었습니다."
            showAlert = true
        } catch let error {
            alertTitle = "로그아웃 실패"
            alertMessage = "오류가 발생했습니다: \(error.localizedDescription)"
            showAlert = true
        }
    }

    // 탈퇴 로직
    func deleteAccountForGoogleUser() {
        guard let user = Auth.auth().currentUser else {
            alertTitle = "탈퇴 실패"
            alertMessage = "현재 사용자 정보를 찾을 수 없습니다."
            showAlert = true
            return
        }

        guard let idToken = GIDSignIn.sharedInstance.currentUser?.idToken?.tokenString else {
            alertTitle = "재인증 실패"
            alertMessage = "구글 인증 정보를 찾을 수 없습니다."
            showAlert = true
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: "")

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                alertTitle = "재인증 실패"
                alertMessage = "오류가 발생했습니다: \(error.localizedDescription)"
                showAlert = true
                return
            }

            user.delete { error in
                if let error = error {
                    alertTitle = "탈퇴 실패"
                    alertMessage = "오류가 발생했습니다: \(error.localizedDescription)"
                } else {
                    alertTitle = "탈퇴 완료"
                    alertMessage = "성공적으로 계정이 삭제되었습니다."
                }
                showAlert = true
            }
        }
    }

    func checkUserProviderAndDelete() {
        guard let user = Auth.auth().currentUser else {
            alertTitle = "탈퇴 실패"
            alertMessage = "사용자를 찾을 수 없습니다."
            showAlert = true
            return
        }

        if let providerData = user.providerData.first {
            if providerData.providerID == GoogleAuthProviderID {
                deleteAccountForGoogleUser()
            } else if providerData.providerID == EmailAuthProviderID {
                showPasswordAlert()
            } else {
                alertTitle = "탈퇴 실패"
                alertMessage = "지원되지 않는 인증 방식입니다."
                showAlert = true
            }
        }
    }

    // 팝업 종료 후 로그인 화면 이동
    func closePopupAndNavigate() {
        showAlert = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isLogout = true // 팝업 종료 후 로그인 화면으로 이동
        }
    }

    // 비밀번호 확인 팝업 표시 (이메일 사용자)
    func showPasswordAlert() {
        alertTitle = "비밀번호 확인"
        alertMessage = "계정을 삭제하려면 비밀번호를 입력해주세요."
        showAlert = true
    }
}

#Preview {
    SettingView()
}
