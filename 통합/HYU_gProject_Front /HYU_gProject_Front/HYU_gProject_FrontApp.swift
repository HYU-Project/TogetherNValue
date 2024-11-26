//
//  HYU_gProject_FrontApp.swift
//  HYU_gProject_Front
//
//  Created by somin on 11/16/24.
//

import SwiftUI

@main
struct HYU_gProject_FrontApp: App {
    var body: some Scene {
        WindowGroup {
            // 고민해야될 부분!
            // 회원가입 이미 했을 때 > 바로 contentView로 이동
            // 회원가입 안했을 때(회원 탈퇴했을 때) > 카카오/애플 로그인 화면 -> SignUpView로
            // 로그아웃, 로그인 토큰 시간 지난 경우 > 카카오/애플 로그인 화면 -> contentView로
            ContentView()
        }
    }
    
}
