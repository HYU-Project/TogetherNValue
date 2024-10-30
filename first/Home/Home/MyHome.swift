//
//  MyHome.swift
//  Home
//
//  Created by 김현경 on 10/30/24.
//
import SwiftUI

struct MyHome: View {
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 16) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    Text("김무명")
                        .font(.title)
                        .bold()
                    
                    Text("한양대학교 서울캠")
                        .font(.subheadline)
                    
                    Text("컴퓨터소프트웨어학과")
                        .font(.subheadline)
                    
                    Button(action: {
                    }) {
                        Text("프로필 수정")
                            .font(.callout)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 30)
                
                Divider()
                
                HStack {
                    Text("매너 온도")
                        .font(.headline)
                    Spacer()
                    Text("40.5 도")
                        .font(.headline)
                }
                .padding()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("나의 거래")
                        .font(.headline)
                        .padding(.leading)
                    
                    NavigationLink{StarPosts()}label:{
                        HStack(){
                            Image(systemName:"heart")
                            Text("관심 목록")
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .foregroundStyle(.black)
                    
                    NavigationLink{MyPosts()}label:{
                        HStack(){
                            Image(systemName:"pencil")
                            Text("내가 작성한 게시글")
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .foregroundStyle(.black)
                    
                    NavigationLink{ParticipatePosts()}label:{
                        HStack(){
                            Image(systemName:"hand.raised")
                            Text("참여한 거래")
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .foregroundStyle(.black)
    
                }
                .padding(.top)
                
                Divider()

                VStack(alignment: .leading, spacing: 15) {
                    Text("기타")
                        .font(.headline)
                        .padding(.leading)

                    NavigationLink(destination: PolicyView()) {
                        HStack {
                            Text("이용약관 (개인 정보 처리 방침)")
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    NavigationLink(destination: FAQListView()){
                        HStack {
                            Text("자주하는 질문 FAQ")
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    
                    NavigationLink(destination: AccountInfoView()) {
                        HStack {
                            Text("계정 정보")
                            Spacer()
                            Text("카카오 (가입일: 2024.9.7)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
            }
            .navigationTitle("마이홈")
        }
    }
}

#Preview {
    MyHome()
}

