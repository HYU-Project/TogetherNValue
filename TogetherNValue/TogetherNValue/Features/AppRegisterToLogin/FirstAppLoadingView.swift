// 앱 클릭시 로그 로딩 화면
import SwiftUI

struct FirstPageView: View {
    @StateObject private var userManager = UserManager()
    @State private var isActive = false // 다음화면전환여부
    
    var body: some View{
        ZStack{
            Color.skyblue
                .edgesIgnoringSafeArea(.all)
            
            if isActive{
                RootView()
            }
            else{
                VStack(){
                    Image("Mainlogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 350, height: 350)
                    
                    Text("같이N가치")
                        .font(.custom("Noteworthy-Bold", size: 38))
                        .bold()
                        .foregroundStyle(Color.white)
                        .padding(.bottom, 0.1)
                    
                    Text("Together & Value")
                        .font(.custom("Noteworthy-Bold", size: 24))
                        .bold()
                        .foregroundStyle(Color.white)
                }
                .padding(.bottom, 60.0)
            }
        }
        .onAppear{
            // 3초 후에 isActive상태를 true로 바꿔서 다음 페이지로 이동
            DispatchQueue.main.asyncAfter(deadline: .now()+3.0){
                withAnimation{
                    isActive = true
                }
            }
        }
    }
}

#Preview{
    FirstPageView()
        .environmentObject(UserManager())
}
