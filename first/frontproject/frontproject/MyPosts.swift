//
//  StarPosts.swift
//  frontproject
//
//  Created by ace on 10/15/24.
//

import SwiftUI

struct MyPosts: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("← 내가 작성한 게시글")
                .font(.title)
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
                Text("["+String(post.subject)+"]\n\n"+String(post.price)+" 원")
            }
            .frame(height: 100)
            HStack{
                Spacer()
                Text("•••")
                    .border(.black)
            }
            Spacer()
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
        }
        .padding()
    }
}

#Preview {
    MyPosts()
}
