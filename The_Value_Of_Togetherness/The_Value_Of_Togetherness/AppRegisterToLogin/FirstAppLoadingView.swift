//앱 클릭시 로그 로딩 화면
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
                        .frame(width: 450, height: 320)
                    
                    Text("같이의 가치")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color.white)
                    
                    Text("the value of togetherness")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.white)
                }
                .padding(.bottom, 60.0)
            }
        }
        .onAppear{
            //3초 후에 isActive상태를 true로 바꿔서 다음 페이지로 이동
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
