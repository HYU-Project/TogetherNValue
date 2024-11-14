//
//  CommnuityMain.swift
//  CommunityUI
//
//  Created by somin on 11/14/24.
//

import SwiftUI

struct CommunityMain: View {
    var schoolName: String = "한양대학교 서울캠" // 임시로 학교 이름 설정
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    
    @State private var showCreatePostView = false
    
    // 게시물 모델 (나중에 따로 뺄 것)
    struct Post: Identifiable {
        var id = UUID()
        var post_idx: Int
        var imageName: String
        var title: String
        var location: String
        var post_category: String // 공구, 나눔
        var post_categoryType: String // 식재료, 물품, 배달
        var post_status: String // 거래완료, 거래중
        var want_num: Int
        // var createdAt: Date
        // 게시물 업데이트 시간을 받아와서 현재 시간과의 차이 구해야함
        // 게시물 리뷰수
        // 게시물 좋아요 수
    }

    // 더미 게시물 데이터
    var posts = [
        Post(post_idx: 1, imageName: "photo1", title: "Title 1", location: "location1", post_category: "공구",post_categoryType: "배달", post_status: "거래중", want_num: 5),
        Post(post_idx: 2, imageName: "photo2", title: "Title 2", location: "location2", post_category: "공구", post_categoryType: "식재료", post_status: "거래중",want_num: 3),
        Post(post_idx: 3, imageName: "photo3", title: "Title 3", location: "location3", post_category: "공구", post_categoryType: "물품", post_status: "거래완료", want_num: 2)
    ]
    
    
    var body: some View {
        VStack {
            Text(schoolName)
                .font(.title3)
                .fontWeight(.bold)
            
            // 광고 배너
            Text("여기에 광고 배너 들어가기")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal)
            
            HStack {
                
                Button("식재료") {
                selectedCategory = "식재료"
                }
                .frame(width:80.0, height: 50.0)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                                )
                .padding()
                
                Button("물품") {
                selectedCategory = "물품"
                }
                .frame(width:80.0, height: 50.0)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                                )
                .padding()
                
                Button("배달") {
                    selectedCategory = "배달"
                }
                .frame(width:80, height: 50)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                                )
                .padding()
            }
            .padding(.horizontal, 50.0)
            
            HStack {
                TextField("Search", text: $searchText)
                    .background(Color.clear)
                    .padding(.horizontal, 25.0)
                
                Button(action: {
                    // 카테고리(공구, 나눔 / 식재료, 물품, 배달)에 해당하는 게시물만 보여주기
                }){
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.black)
                        .padding()
                }
            }
            
            ZStack {
                ScrollView {
                    // 공구, 나눔에 따라 게시물 보여줘야함
                    VStack(alignment: .leading) {
                        ForEach(posts) { post in
                            NavigationLink(destination: CommunityPost(post_idx: post.post_idx)){
                                HStack() {
                                    Image(post.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 50)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    VStack {
                                        VStack(alignment: .leading) {
                                            Text("[\(post.title)]")
                                                .font(.headline)
                                                .padding(.top, 5)
                                            
                                            Text("5분 전")
                                                .foregroundColor(.secondary)
                                            
                                        }
                                        .padding()
                                        
                                        VStack {
                                            HStack {
                                                Image(systemName: "mappin.and.ellipse")
                                                
                                                Text(post.location)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            HStack{
                                                Image(systemName: "person.fill")
                                                
                                                HStack {
                                                    Text("1") // 실제 참여 인원
                                                    Text("/ \(post.want_num)")
                                                }
                                            }
                                        }
                                    }
                                    
                                    VStack{
                                        Spacer()
                                        
                                        HStack{
                                            HStack {
                                                Button(action: {
                                                    // 게시물 찜하기 버튼
                                                }){
                                                    Image(systemName: "heart")
                                    .foregroundColor(Color.blue)
                                                }
                                                Text("10")// 게시물에 대한 찜하기 개수
                                    .foregroundColor(Color.blue)
                                }
                                HStack{
                                                Image(systemName: "message")
                                                    .foregroundColor(Color.blue)
                                                Text("2")
                                        .foregroundColor(Color.blue)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                        }
                    }
                    .padding()
                    
                }
                .background(Color.white)
                
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            showCreatePostView.toggle()
                        }){
                            Image(systemName: "plus.square.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.black)
                               .padding()
                        }
                        .sheet(isPresented: $showCreatePostView){
                            CreatePostView() // 게시물 작성 창
                        }
                    }
                }
            }
    
    
        }
        .padding()
        
    }
}

#Preview {
    CommunityMain()
}
