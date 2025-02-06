//
//  PostListView.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import SwiftUI
import FirebaseFirestore

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
            if let postImageUrl = postImageUrl, let url = URL(string: postImageUrl) {
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
            
            if post.post_status == "거래완료"{
                HStack{
                    Text(post.post_status)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)
                }
            }
            else {
                HStack{
                    Text(post.post_status)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)
                }
            }


            HStack {
                Image(systemName: "person.fill")
                Text("\(post.active_chatRoomCnt) / \(post.want_num)") // 인원 수는 채팅방에서 1:1 거래완료 카운트
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
