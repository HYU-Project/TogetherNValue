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
            // signUp, consent View 완성하고 바꾸기
            //if hasUserConsented(){
              //  ConsentView() // 동의 화면을 이미 본 경우
            //}
            //else{
              //  SignupView() // 동의가 필요하면 회원가입 및 동의 화면 표시
            //}
            ConsentView()
        }
    }
    
    // 사용자 동의 여부 확인
    func hasUserConsented() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasUserConsented")
    }
}
