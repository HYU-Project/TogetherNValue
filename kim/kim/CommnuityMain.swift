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
    


    // 더미 게시물 데이터
    var posts = [
        Post(post_idx: 1, imageName: "mushroom", title: "유기농버섯 공구해욤", location: "한플", post_category: "공구",post_categoryType: "식재료", post_status: "거래중", want_num: 4, user_idx: "김소민", post_content: "친구 이모가 버섯키우시는데 완전 유기농이에요!! 한 박스 8000원이고 4박스 이상이면 무료배송!", post_created_at: "2024-11-10 18:00"),
        Post(post_idx: 2, imageName: "hamburger", title: "같이 햄버거 먹으실분! 배달비 무료~", location: "잇빗관", post_category: "공구", post_categoryType: "배달", post_status: "거래중",want_num: 2, user_idx: "김현경", post_content: "햄버거 배달 최소금액이 15000원이라서 같이 시키실분 한분 구합니다~ 12시 30까지 연락주세요", post_created_at: "2024-11-12 12:00"),
        Post(post_idx: 3, imageName: "tissue", title: "두루마리 휴지 같이 사실분", location: "무관", post_category: "공구", post_categoryType: "물품", post_status: "거래완료", want_num: 3, user_idx: "김경진", post_content: "18개짜리 구매하려고 하는데 너무 많아요. 가격은 인당 3000 생각중이에요", post_created_at: "2024-11-13 16:00" ),
        Post(post_idx: 4, imageName: "potato", title: "감자 나눔합니다.", location: "한플 앞", post_category: "나눔", post_categoryType: "식재료", post_status: "거래완료", want_num: 2, user_idx: "김무명", post_content: "저희집에 강원도에서 감자 농사 짓는데, 이번에 수확이 잘되서 학우분들 중 필요하신 분 나눠드리려고 합니다.", post_created_at: "2023-12-13 12:30"),
        Post(post_idx: 5, imageName: "hamburger", title: "맘스터치 햄버거 나눔합니다.", location: "학생회관 앞", post_category: "나눔", post_categoryType: "배달", post_status: "거래중", want_num: 5, user_idx: "이아무", post_content: "햄버거 많이 시켰는데 남아서 나눔합니다.", post_created_at: "2024-11-13 15:50"),
        Post(post_idx: 6, imageName: "potSet", title: "냄비세트에서 1번 나눔합니다.", location: "ftc 3층", post_category: "나눔", post_categoryType: "물품", post_status: "거래중", want_num: 5, user_idx: "송송이", post_content: "냄비세트 중에 하나 필요 없어서 나눔 게시물 올립니다.", post_created_at: "2024-10-25 19:25")
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
                            NavigationLink(destination: PostDetailView(post: post)){
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
    var user_idx: String
    var post_content: String
    var post_created_at: String
}

#Preview {
    ContentView(selection: 0)
}
