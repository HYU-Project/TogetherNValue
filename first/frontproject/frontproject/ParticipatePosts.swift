//
//  StarPosts.swift
//  frontproject
//
//  Created by ace on 10/15/24.
//

import SwiftUI

struct ParticipatePosts: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("← 참여한 거래")
                .font(.title)
            Divider()
            HStack{
                Image(systemName: "")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 5))
                Text("["+String(post.subject)+"]\n\n"+String(post.price)+" 원")
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
            }
            Spacer()
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
        }
        .padding()
    }
}

#Preview {
    ParticipatePosts()
}
