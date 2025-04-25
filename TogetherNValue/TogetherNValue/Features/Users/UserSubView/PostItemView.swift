//
//  PostItemView.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import SwiftUI

struct PostItemView: View {
    var post: MyPost
    var showOptions: (MyPost) -> Void
    
    var body: some View {
        NavigationLink(destination: DetailPost(post_idx: post.post_idx)) {
            HStack(spacing: 20) {
                if let postImageUrl = post.postImage_url, !postImageUrl.isEmpty {
                    // 로컬 파일 경로 처리
                    if postImageUrl.starts(with: "file://"), let url = URL(string: postImageUrl) {
                        let localFileURL = URL(fileURLWithPath: url.path)  // file:// 프로토콜을 처리하는 방식
                        if let uiImage = UIImage(contentsOfFile: localFileURL.path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        } else {
                            Image("NoImage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        }
                    } else if let url = URL(string: postImageUrl) {
                        // URL로 이미지 로드
                        AsyncImage(url: url) { phase in
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
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image("NoImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    }
                } else {
                    // 이미지가 없을 경우
                    Image("NoImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(Color.black)
                        .padding(.bottom, 5)
                    
                    Text("#\(post.post_category) #\(post.post_categoryType)")
                        .foregroundColor(.gray)
                
                }
                
                Spacer()
                
                VStack {
                    Button(action: {
                        showOptions(post)
                    }) {
                        Image("appSetting")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                    }
                    .padding(.top, 5)
                }
            }
            .padding()
            .frame(height: 100)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 3)
        }
    }
}
