/import SwiftUI

struct WithdrawalConfirmationView: View {
    var body: some View {
        VStack(spacing: 20) {
            // 상단 메시지
            Text("탈퇴 시 아래 정보가 모두 사라져요")
                .font(.title2)
                .bold()
                .padding(.top, 50)
            
            Spacer()
            
            // 하단 확인 메시지
            Text("그래도 탈퇴하시겠어요?")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 회원 탈퇴하기 버튼
            Button(action: {
                // 회원 탈퇴 처리 로직
                print("회원 탈퇴 처리됨")
            }) {
                Text("회원 탈퇴하기")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button(action: {
            // 닫기 버튼 동작
            print("닫기 버튼 눌림")
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.black)
        })
    }
}

struct WithdrawalConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalConfirmationView()
    }
}
