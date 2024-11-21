
//  ContentView : 화면 이동 뷰

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            TabView {
                GroupPurchaseMain()
                    .tabItem {
                        Label("공구", systemImage: "figure.2")
                    }
                GroupSharingMain()
                    .tabItem {
                        Label("나눔", systemImage: "heart.text.clipboard")
                    }
                ChatListMain()
                    .tabItem {
                        Label("채팅", systemImage: "ellipsis.message.fill")
                    }
                MyHomeMain()
                    .tabItem {
                        Label("마이홈", systemImage: "house")
                    }
            }
        }
        .tint(.black)
    }
}

#Preview {
    ContentView()
}

