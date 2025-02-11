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
    
    private let interestedPostService = InterestedPostService()

    var body: some View {
        HStack (spacing: 10){
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
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                
                Text("#\(post.post_category) #\(post.post_categoryType)")
                    .foregroundColor(.gray)
                
                Text(post.post_status)
                    .padding()
                    .font(.subheadline)
                    .frame(minWidth: 25, minHeight: 20)
                    .foregroundColor(.white)
                    .background(post.post_status == "거래가능" ? Color.green : Color.black)
                    .cornerRadius(5)
                
            }
            
            Spacer()
            
            VStack{
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
                .padding(.bottom , 10)
                
                // 좋아요 수
                HStack{
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                    
                    Text("\(post.post_likeCnt)")
                        .foregroundColor(.black)
                }
            }
            .padding()
        }
        .padding()
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

