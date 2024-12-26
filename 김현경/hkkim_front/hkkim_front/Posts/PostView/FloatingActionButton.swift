//
//  FloatingActionButton.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import SwiftUI

struct FloatingActionButton: View {
    @Binding var showCreatePostView: Bool
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showCreatePostView.toggle()
                }) {
                    Image(systemName: "plus.square.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.black)
                        .padding()
                }
                .sheet(isPresented: $showCreatePostView) {
                    CreatePostView() // 게시물 작성 창
                }
            }
        }
    }
}

