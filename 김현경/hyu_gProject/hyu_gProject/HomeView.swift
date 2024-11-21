//첫 홈 화면

import SwiftUI

struct HomeView: View {
    @State private var schoolName: String = "한양대학교 서울캠"
    
    var body: some View {
        NavigationView {
            VStack{
                Text("광고 배너 위치")
                    .frame(maxWidth: .infinity)
                    .frame(height:70)
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(8)
                    .padding(.top, 5)
                
                Spacer()
                
                HStack{
                    Text("  > ")
                        
                    Text(schoolName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading, 1)
                    Spacer()
                }
                
                Spacer()
                
                NavigationLink(destination: GroupPurchaseView()) {
                    Text("공구")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 270, height: 90)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(destination: FreeSharingView()) {
                    Text("나눔")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 270, height: 90)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(destination: ChatListView()) {
                    Text("채팅")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 270, height: 90)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(destination: MyHomeView()) {
                    Text("마이홈")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 270, height: 90)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("")
        }
    }
}

#Preview{
    HomeView()
}
