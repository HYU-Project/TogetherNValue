//로그인 화면 구현

import SwiftUI

struct LogInView: View{
    //@State private var logo: String = ""
    @State private var id: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    var body: some View {
        VStack{
            Text("'나'와 '너'를 잇는 가치 있는 공간")
                .font(.title3)
                .bold()
            
            Image("logo")
                .resizable()
                .frame(width: 350, height:300)
                .padding(.bottom, 20)
            

            Image("kakao_login")
                .resizable()
                .frame(width:400,height:200)
            
            
        }
        .padding()
        
    }
    
   
}

#Preview{
    LogInView()
}
