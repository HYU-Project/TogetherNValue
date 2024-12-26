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
        .frame(width: 330, height: 100)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct SharingPostImageView: View {
    var postImageUrl: String?
    
    var body: some View {
        ZStack {
            if let postImageUrl = postImageUrl {
                if postImageUrl.starts(with: "file://"), let url = URL(string: postImageUrl) {
                    if let uiImage = UIImage(contentsOfFile: url.path) {
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
                            .onAppear {
                                print("Failed to load local image: \(url.path)")
                            }
                    }
                } else if let url = URL(string: postImageUrl) {
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
                                .onAppear {
                                    print("Failed to load image from URL: \(url)")
                                }
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
                        .onAppear {
                            print("Invalid URL: \(postImageUrl)")
                        }
                }
            } else {
                Text("No image available")
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
                    .onAppear {
                        print("No image URL provided")
                    }
            }
        }
    }
}

struct SharingPostInfoView: View {
    var post: SharingPost
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(post.title)
                .font(.headline)

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

