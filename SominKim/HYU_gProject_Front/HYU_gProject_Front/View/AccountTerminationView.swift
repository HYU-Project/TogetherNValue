
//  AccountTerminationView : 회원 탈퇴 이유

import SwiftUI

struct AccountTerminationView: View {
    @State private var selectedReasons: [String] = []
    @State private var isDirectInputSelected = false
    @State private var directInputText = ""
    
    let reasons = [
        "기대했던 앱이 아니에요",
        "공구를 그만뒀어요",
        "직접 입력"
    ]
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading, spacing: 20) {
                
                VStack {
                    Text("탈퇴하려는 ")
                        .font(.title)
                        .bold()
                        .padding(.trailing, 70)
                    
                    Text("이유를 알려주세요")
                        .font(.title)
                        .bold()
                }
                
                
                Text("*중복 선택 가능")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                // 이유 선택 버튼들
                ForEach(reasons, id: \.self) { reason in
                    Button(action: {
                        if selectedReasons.contains(reason) {
                            selectedReasons.removeAll { $0 == reason }
                        } else {
                            selectedReasons.append(reason)
                        }
                        
                        if reason == "직접 입력" {
                            isDirectInputSelected.toggle()
                        }
                    }) {
                        HStack {
                            Text(reason)
                            Spacer()
                            if selectedReasons.contains(reason) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                
                // 직접 입력 필드가 나타나는 부분
                if isDirectInputSelected {
                    TextField("더 나은 앱이 될 수 있도록 의견을 들려주세요", text: $directInputText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Spacer()
                
                // 다음 버튼 -> 탈퇴 확인 페이지로 이동
                NavigationLink(destination: WithdrawalConfirmationView()) {
                    Text("다음")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview {
    AccountTerminationView()
}
