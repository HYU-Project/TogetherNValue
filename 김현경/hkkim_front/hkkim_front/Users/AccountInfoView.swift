//
//  AccountInfoView.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct AccountInfoView: View {
    @EnvironmentObject var userManager: UserManager
    
    @State private var alertTitle = "" // 팝업 제목
    @State private var alertMessage = "" // 팝업 메시지
    @State private var isLogout = false // 로그인 화면으로 이동 여부
    @State private var showAlert = false // 팝업 표시 여부
    @State private var isShowingPasswordSheet = false // 비밀번호 입력 Sheet 표시
    @State private var passwordInput = "" // 탈퇴 시 비밀번호 입력
    
    var body: some View {
        List{
            Button(action: {
                logOut()
            }) {
                Text("로그아웃")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                checkUserProviderAndDelete()
            }) {
                Text("탈퇴하기")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.red)
            }
        }
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
    
    func logOut() {
        do {
            try userManager.logOut() // Firebase 로그아웃
            GIDSignIn.sharedInstance.signOut() // Google 로그아웃
            alertTitle = "로그아웃 완료"
            alertMessage = "성공적으로 로그아웃되었습니다."
        } catch let error {
            alertTitle = "로그아웃 실패"
            alertMessage = "오류가 발생했습니다: \(error.localizedDescription)"
        }
        showAlert = true
    }
    
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
    AccountInfoView()
        .environmentObject(UserManager())
}
