//내가 작성한 게시물
import SwiftUI

struct MyPosts: View {
    @Environment(\.dismiss) private var dismiss
    @State var threedot = false
    var body: some View {
        VStack(alignment: .leading){
            Divider()
            HStack{
                Spacer()
                Text("거래진행중 1")
                Spacer()
                Text("거래완료 1")
                Spacer()
            }
            Divider()
            HStack{
                Image(systemName: "")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 5))
                var str = "["+String(post.subject)+"]\n\n"+String(post.price)+" 원"
                Text(str)
            }
            .frame(height: 100)
            HStack{
                Spacer()
                Text("•••")
                    .border(.black)
                    .onTapGesture {
                        threedot.toggle()
                    }
            }
            Spacer()
            if threedot{
            HStack {
                Spacer()
                Text("거래 완료")
                Spacer()
            }
            .border(.black)
                HStack {
                    Spacer()
                    Text("게시글 수정")
                    Spacer()
                }
                .border(.black)
                HStack {
                    Spacer()
                    Text("게시글 삭제")
                    Spacer()
                }
                .border(.black)
                HStack {
                    Spacer()
                    Text("닫기")
                    Spacer()
                }
                .border(.black)
                .onTapGesture{
                    threedot = false
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .topBarLeading){
                HStack{
                    Button{
                        dismiss()
                    }label:{
                        Text("←")
                            .font(.title)
                    }
                    Text("내가 작성한 게시글")
                        .font(.title)
                }
            }
        }
    }
}

#Preview {
    MyPosts()
}
