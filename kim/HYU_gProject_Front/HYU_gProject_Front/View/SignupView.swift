
//  SignupView.swift : 회원가입 ui

import SwiftUI

struct SignupView: View {
    var body: some View {
        
        
        Button(action: {
        // 회원가입 완료 버튼 클릭시 app뷰인 HYU_gProject_FrontApp.swift에서 contentView로 이동하게 됨
        UserDefaults.standard.set(true, forKey: "hasUserConsented")
        }){
            Text("Submit")
                .font(.title)
                .bold()
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

#Preview {
    SignupView()
}
