
import SwiftUI

struct ContentView: View {
    @StateObject var userManager = UserManager()
    var body: some View {
        NavigationStack{
            TabView {
                GroupPurchaseMain()
                    .tabItem {
                        Label("공구", systemImage: "figure.2")
                    }
                    .environmentObject(userManager)
                GroupSharingMain()
                    .tabItem {
                        Label("나눔", systemImage: "heart.text.clipboard")
                    }
                    .environmentObject(userManager)
                ChatListMain()
                    .tabItem {
                        Label("채팅", systemImage: "ellipsis.message.fill")
                    }
                MyHomeMain()
                    .tabItem {
                        Label("마이홈", systemImage: "house")
                    }
                    .environmentObject(userManager)
            }
        }
        .tint(.black)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
}
