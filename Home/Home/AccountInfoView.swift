import SwiftUI

struct AccountInfoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                // 로그아웃 동작
                print("로그아웃 버튼 클릭됨")
            }) {
                Text("로그아웃")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: AccountTerminationView()){
                Text("회원탈퇴")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("계정 정보")
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView()
    }
}
