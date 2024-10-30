//
//  StarPosts.swift
//  frontproject
//
//  Created by ace on 10/15/24.
//

import SwiftUI

struct ParticipatePosts: View {
    @Environment(\.dismiss) private var dismiss
    @State var threedot = false
    var body: some View {
        VStack(alignment: .leading){
            Divider()
            HStack{
                Image(systemName: "")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 5))
                var str = "["+String(post.subject)+"]\n\n"+String(post.price)+" 원"
                Text(str)
                Spacer()
            }
            .frame(height: 100)
            HStack() {
                Spacer()
                Text("거래완료")
                Spacer()
            }
            HStack{
                Spacer()
                Text("후기(평가) 남기기")
                    .border(.black)
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
                    Text("목록에서 지우기")
                    Spacer()
                }
                .border(.black)
                HStack {
                    Spacer()
                    Text("닫기")
                    Spacer()
                }
                .border(.black)
                .onTapGesture {
                    threedot.toggle()
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
                    Text("참여한 거래")
                        .font(.title)
                }
            }
        }
    }
}

#Preview {
    ParticipatePosts()
}
