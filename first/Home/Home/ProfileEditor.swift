//
//  StarPosts.swift
//  frontproject
//
//  Created by ace on 10/15/24.
//

import SwiftUI

struct ProfileEditor: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack{
            Text("프로필 수정")
            Image("pngprofile")
            Text("프로필 사진만 변경 가능").foregroundStyle(.red)
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 100)
                .overlay(
                    VStack {
                        Text("김무명")
                        Text("한양대학교 서울캠")
                        Text("컴퓨터소프트웨어학과")
                    }.foregroundStyle(.gray)
                )
                .foregroundStyle(.gray.opacity(0.1))
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 5)
                .frame(height: 50)
                .overlay(
                    Text("학교 재인증")
                )
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .topBarLeading){
                HStack{
                    Button{
                        dismiss()
                    }label:{
                        Text("←")
                            .font(.title)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileEditor()
}
