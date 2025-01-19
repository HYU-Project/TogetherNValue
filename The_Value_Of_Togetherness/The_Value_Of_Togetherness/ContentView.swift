
import SwiftUI

struct ContentView: View {
    @StateObject var userManager = UserManager()
    @StateObject var purchaseViewModel = GroupPurchaseViewModel()
    @State var selectedTab = 1

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                GroupPurchaseMain(viewModel: purchaseViewModel)
                    .tabItem {
                        Label("공구", systemImage: "figure.2")
                    }
                    .tag(1)
                
                GroupSharingMain()
                    .tabItem {
                        Label("나눔", systemImage: "heart.text.clipboard")
                    }
                    .tag(2)
                
                ChatListMain()
                    .tabItem {
                        Label("채팅", systemImage: "ellipsis.message.fill")
                    }
                    .tag(3)
                    
                MyHomeMain()
                    .tabItem {
                        Label("마이홈", systemImage: "house")
                    }
                    .tag(4)
            }
            .environmentObject(userManager)
            .tint(.black)
            .navigationBarBackButtonHidden(true)
            .onChange(of: userManager.userId) { userId in
                if let userId = userId {
                    print("로그인된 사용자: \(userId)")
                    purchaseViewModel.fetchSchoolName(userId: userId)
                } else {
                    print("로그인된 유저가 없습니다.")
                }
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(UserManager())
}
