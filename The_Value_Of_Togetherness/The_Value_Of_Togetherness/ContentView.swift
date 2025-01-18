
import SwiftUI

struct ContentView: View {
    @StateObject var userManager = UserManager()
    @State var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            GroupPurchaseMain()
            .tabItem {
                Label("공구", systemImage: "figure.2")
            }
            .tag(1)
            .environmentObject(userManager)
            
            GroupSharingMain()
            .tabItem {
                Label("나눔", systemImage: "heart.text.clipboard")
            }
            .tag(2)
            .environmentObject(userManager)
            
            
            ChatListMain()
            .tabItem {
                Label("채팅", systemImage: "ellipsis.message.fill")
            }
            .tag(3)
            .environmentObject(userManager)
            
            MyHomeMain()
            .tabItem {
                Label("마이홈", systemImage: "house")
            }
            .tag(4)
            .environmentObject(userManager)
        
        }
        .tint(.black)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
}
