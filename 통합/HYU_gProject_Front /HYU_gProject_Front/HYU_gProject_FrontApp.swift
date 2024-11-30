//
//  HYU_gProject_FrontApp.swift
//  HYU_gProject_Front
//
//  Created by somin on 11/16/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Firebase 초기화
        FirebaseApp.configure()
        return true
    }
}

@main
struct HYU_gProject_FrontApp: App {
    
    // 앱 델리게이트 등록
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Firebase 초기화 상태에 따라 ContentView를 보여줌
    @State private var isFirebaseConfigured = false
    
    var body: some Scene {
        WindowGroup {
            // 고민해야될 부분!
            // 회원가입 이미 했을 때 > 바로 contentView로 이동
            // 회원가입 안했을 때(회원 탈퇴했을 때) > 카카오/애플 로그인 화면 -> SignUpView로
            // 로그아웃, 로그인 토큰 시간 지난 경우 > 카카오/애플 로그인 화면 -> contentView로
            if isFirebaseConfigured {
                SignupView()
                //ContentView() // Firebase 초기화 후 ContentView 표시
            } else {
                ProgressView() // Firebase 초기화 중에는 로딩 화면을 표시
                    .onAppear {
                        // Firebase 초기화 완료 후 ContentView로 전환
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isFirebaseConfigured = true
                        }
                    }
            }
        }
    }
    
}
