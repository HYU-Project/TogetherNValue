import SwiftUI

struct Me{
    var id = 202020
    var name = "김무명"
    var univCamp = "한양대학교 서울캠"
    var department = "컴퓨터소프트웨어학과"
    var profileImage = Image("SCPC_2024_Poster")
    var temperature = 40.5
    var myPost: Set<Int> = [1]
    var starPost: Set<Int> = [1]
    var participatePost: Set<Int> = [1]
}
struct Post{
    var id = 1
    var subject = "주제"
    var price = 80050
    var leader = 202020
    var completed = false
    var image = Image("SCPC_2024_Poster")
}
var me = Me()
var post = Post()
struct ContentView: View {
    var body: some View {
        NavigationStack{
            TabView {
                SwiftUIView()
                    .tabItem {
                        Label("공구", systemImage: "book")
                    }
                MyHome()
                    .tabItem {
                        Label("나눔", systemImage: "book")
                    }
                SwiftUIView()
                    .tabItem {
                        Label("채팅", systemImage: "book")
                    }
                MyHome()
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
