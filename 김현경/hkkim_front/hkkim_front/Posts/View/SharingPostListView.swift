//
//  SharingPostListView.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import SwiftUI

struct SharingPostListView: View {
    var posts: [SharingPost]
    var filteredPosts: [SharingPost]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(filteredPosts) { post in
                        NavigationLink(destination: DetailPost(post_idx: post.post_idx)) {
                            SharingPostRow(post: post)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct SharingPostRow: View {
    var post: SharingPost
    
    var body: some View {
        HStack {
            SharingPostImageView(postImageUrl: post.postImage_url)
            SharingPostInfoView(post: post)
            SharingPostStatsView(post: post)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct SharingPostImageView: View {
    var postImageUrl: String?
    
    var body: some View {
        if let postImageUrl = postImageUrl {
            // URL이 "file://"로 시작하는 경우
            if postImageUrl.starts(with: "file://"), let url = URL(string: postImageUrl) {
                // 로컬 파일 경로에서 이미지 로드
                Image(uiImage: UIImage(contentsOfFile: url.path) ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else if let url = URL(string: postImageUrl) {
                // 일반 URL에서 이미지 로드
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        } else {
            Text("No image URL") // URL이 없으면 메시지 출력
        }
    }
}

struct SharingPostInfoView: View {
    var post: SharingPost
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("[\(post.title)]")
                .font(.headline)

            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(post.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "person.fill")
                Text("\(post.want_num) / \(post.want_num)")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SharingPostStatsView: View {
    var post: SharingPost
    
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

