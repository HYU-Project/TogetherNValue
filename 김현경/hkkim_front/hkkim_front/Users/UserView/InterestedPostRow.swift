//
//  InterestedPostRow.swift
//  hkkim_front
//
//  Created by 김소민 on 1/7/25.
//

import SwiftUI

struct InterestedPostRow: View {
    let post: InterestedPost
    let toggleLikeAction: (InterestedPost) -> Void

    var body: some View {
        HStack(spacing: 16) {
            if let imageUrl = URL(string: post.postImage_url ?? "NoImage") {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    case .failure:
                        Image("NoImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image("NoImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }

            // 텍스트와 버튼 섹션
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                Text(post.post_status)
                    .font(.subheadline)
                    .foregroundColor(post.post_status == "거래중" ? .red : .green)
            }

            Spacer()

            // 좋아요 버튼
            Button(action: {
                toggleLikeAction(post)
            }) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(height: 90) // 원하는 높이 설정
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

