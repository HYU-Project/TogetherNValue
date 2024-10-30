//
//  StarPosts.swift
//  frontproject
//
//  Created by ace on 10/15/24.
//

import SwiftUI

struct StarPosts: View {
    // 예시 데이터
    let post = (subject: "상품명", price: 10000)

    var body: some View {
        VStack(alignment: .leading) {
            Text("← 관심 목록")
                .font(.title)
            Divider()
            
            HStack {
                Image(systemName: "photo") // 적절한 시스템 이미지 이름으로 변경
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
                
                VStack {
                    Text("♥")
                        .font(.title)
                    Spacer()
                }
            }
            .frame(height: 100)
            
            HStack {
                Spacer()
                Text("거래완료")
                Spacer()
            }
            
            Divider()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    StarPosts()
}
