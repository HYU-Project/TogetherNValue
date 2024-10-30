//
//  StarPosts.swift
//  frontproject
//
//  Created by ace on 10/15/24.
//

import SwiftUI

struct MyPosts: View {
    // 예시 데이터 (실제 post 데이터가 있다면 이 부분 수정)
    let post = (subject: "상품명", price: 10000)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("← 내가 작성한 게시글")
                .font(.title)
            Divider()
            
            HStack {
                Spacer()
                Text("거래진행중 1")
                Spacer()
                Text("거래완료 1")
                Spacer()
            }
            
            Divider()
            
            HStack {
                Image(systemName: "photo") // 아이콘 이름 예시
                    .resizable()
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 5)
                    )
                
                // 복잡한 텍스트 표현을 별도로 분리
                let postInfo = "[\(post.subject)]\n\n\(post.price) 원"
                Text(postInfo)
            }
            .frame(height: 100)
            
            HStack {
                Spacer()
                Text("•••")
                    .border(Color.black)
            }
            
            Spacer()
            
            // 버튼 스타일 통일화
            VStack(spacing: 10) {
                Text("거래 완료")
                Text("게시글 수정")
                Text("게시글 삭제")
                Text("닫기")
            }
            .frame(maxWidth: .infinity)
            .border(Color.black)
        }
        .padding()
    }
}

#Preview {
    MyPosts()
}
