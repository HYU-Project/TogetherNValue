//
//  MyHome.swift
//  frontproject
//
//  Created by ace on 10/15/24.
//

import SwiftUI

struct MyHome: View {
    var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("마이홈")
                        .font(.title)
                }
                HStack{
                    VStack{
                        me.profileImage
                            .resizable()
                            .clipShape(.circle)
                        Button(action: {
                            print("Hello")
                        }){
                            Text("프로필 수정")
                        }
                        .buttonStyle(.bordered)
                    }
                    VStack{
                        Text(me.name)
                        Text(me.univCamp)
                        Text(me.department)
                    }
                }
                Divider()
                HStack{
                    Text("매너 온도")
                    Text(String(me.temperature)+"도")
                }
                Divider()
                Text("나의 거래")
                    .font(.title2)
                NavigationLink{StarPosts()}label:{
                    HStack(){
                        Image("Heart")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("관심 목록")
                    }
                }
                .foregroundStyle(.black)
                NavigationLink{MyPosts()}label:{
                    HStack{
                        Image("post")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("내가 작성한 게시글")
                    }
                }
                .foregroundStyle(.black)
                NavigationLink{ParticipatePosts()}label:{
                    HStack{
                        Image("Handshake")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("참여한 거래")
                    }
                }
                .foregroundStyle(.black)
                Divider()
                HStack{
                    Text("기타")
                        .font(.title2)
                }
                Text("이용약관(개인 정보 처리 방침)\n자주하는 질문 FAQ")
                HStack {
                    Text("계정 정보")
                    Spacer()
                    Text("카카오 (가입일: 2024.9.7)")
                }
            }
            .padding()
    }
}

#Preview {
    MyHome()
}
