//앱 클릭시 로그 로딩 화면
import SwiftUI

struct FirstPageView: View {
    @State private var isActive = false //다음화면전환여부
    var body: some View{
        ZStack{
            if isActive{
                RootView()
            }else{
                Color.black
                    .opacity(0.95)
                    .ignoresSafeArea()
                VStack(){
                    Text("같이의 가치")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
        }
        .onAppear{
            //3초 후에 isActive상태를 true로 바꿔서 다음 페이지로 이동
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                withAnimation{
                    isActive = true
                }
            }
        }
    }
}

#Preview{
    FirstPageView()
}
