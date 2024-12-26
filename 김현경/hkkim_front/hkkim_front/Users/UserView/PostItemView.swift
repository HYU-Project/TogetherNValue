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
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
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
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    }
                } else {
                    // 이미지가 없을 경우
                    Text("No image available")
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(post.post_status)
                        .font(.subheadline)
                        .foregroundColor(post.post_status == "거래중" ? .red : .green)
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
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
        }
    }
}
