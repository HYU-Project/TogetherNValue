//
//  StarPosts.swift
//  frontproject
//
//  Created by ace on 10/15/24.
//

import SwiftUI

struct ParticipatePosts: View {
    // 예시 데이터
    let post = (subject: "상품명", price: 10000)

    var body: some View {
        VStack(alignment: .leading) {
            Text("← 참여한 거래")
                .font(.title)
            Divider()
            
            HStack {
                Image(systemName: "photo") // 아이콘 이름 예시
                    .resizable()
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 5)
                    )
                
                // 텍스트 표현 분리
                let postInfo = "[\(post.subject)]\n\n\(post.price) 원"
                Text(postInfo)
                
                Spacer()
            }
            .frame(height: 100)
            
            HStack {
                Spacer()
                Text("거래완료")
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("후기(평가) 남기기")
                    .border(Color.black)
                Text("•••")
                    .border(Color.black)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text("목록에서 지우기")
                Spacer()
            }
            .border(Color.black)
            
            HStack {
                Spacer()
                Text("닫기")
                Spacer()
            }
            .border(Color.black)
        }
        .padding()
    }
}

#Preview {
    ParticipatePosts()
}
