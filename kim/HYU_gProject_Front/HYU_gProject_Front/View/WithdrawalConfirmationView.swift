
//  WithdrawalConfirmationView : 회원탈퇴 마지막

import SwiftUI

struct WithdrawalConfirmationView: View {
    var body: some View {
        
        VStack(spacing: 20) {
            // 상단 메시지
            VStack {
                Text("탈퇴 시 아래 정보가")
                    .font(.title)
                    .bold()
                    .padding(.trailing, 135)
                
                Text("모두 사라져요")
                    .font(.title)
                    .bold()
                    .padding(.trailing, 200)
            }
            
            
           // TabView로 앱 기능 이미지 자동으로 넘어가도록
            Spacer()
            
            // 하단 확인 메시지
            Text("그래도 탈퇴하시겠어요?")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 회원 탈퇴하기 버튼
            Button(action: {
                // 회원 탈퇴 처리 로직 처리 후 처음 앱 화면으로 이동
            }) {
                Text("회원 탈퇴하기")
                    .foregroundColor(Color.black)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.bottom, 30)
        }
        .padding()
    }
}

#Preview {
    WithdrawalConfirmationView()
}
