//
//  PostListView.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import SwiftUI

struct PurchasePostListView: View {
    var posts: [PurchasePost]
    var filteredPosts: [PurchasePost]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(filteredPosts) { post in
                        NavigationLink(destination: DetailPost(post_idx: post.post_idx)) {
                            PurchasePostRow(post: post)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct PurchasePostRow: View {
    var post: PurchasePost
    
    var body: some View {
        HStack {
            PurchasePostImageView(postImageUrl: post.postImage_url)
            PurchasePostInfoView(post: post)
            PurchasePostStatsView(post: post)
        }
        .padding()
        .frame(width: 330, height: 100)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct PurchasePostImageView: View {
    var postImageUrl: String?
    
    var body: some View {
        ZStack {
            if let postImageUrl = postImageUrl {
                if postImageUrl.starts(with: "file://"), let url = URL(string: postImageUrl) {
                    // 로컬 파일 경로 처리
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
            } else {
                Text("No image available")
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
            }

        }
    }
}


struct PurchasePostInfoView: View {
    var post: PurchasePost
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(post.title)
                .font(.subheadline)

            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(post.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "person.fill")
                Text("1 / \(post.want_num)") // 인원 수는 participant를 통해 비동기적으로 추가하기
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PurchasePostStatsView: View {
    var post: PurchasePost
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "heart")
                Text("\(post.post_likeCnt)")
                Image(systemName: "message")
                Text("\(post.post_commentCnt)")
            }
        }
    }
}
