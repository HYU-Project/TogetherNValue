// PolicyView : MyMainHome에서

import SwiftUI

struct PolicyView: View {
    
    var body: some View {
        
        VStack(spacing: 20) {
            Text("이용약관 및 개인정보 처리방침")
                .font(.title)
                .bold()
                .padding()
            
            Text("이 앱의 이용약관 및 개인정보 처리방침은 아래 링크에서 확인하실 수 있습니다.")
                .font(.body)
                .padding()
        }
        .padding()
    }
}

#Preview {
    PolicyView()
}

