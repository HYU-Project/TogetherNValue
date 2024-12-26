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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct PurchasePostImageView: View {
    var postImageUrl: String?
    
    var body: some View {
        if let postImageUrl = postImageUrl, let url = URL(string: postImageUrl) {
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
    }
}

struct PurchasePostInfoView: View {
    var post: PurchasePost
    
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
