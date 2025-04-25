//
//  PostFilterView.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import SwiftUI

struct PostFilterView: View {
    @Binding var selectedPostStatus: String
    var loadPosts: () -> Void
    
    var body: some View {
        HStack(spacing: 30) {
            ForEach(["거래가능", "거래완료"], id: \.self) { status in
                Button(action: {
                    selectedPostStatus = selectedPostStatus == status ? "" : status
                    loadPosts()
                }) {
                    Text(status)
                        .bold()
                        .frame(width: 150, height: 50)
                        .foregroundColor(selectedPostStatus == status ? .white : .black)
                        .background(selectedPostStatus == status ? Color.blue : Color.clear)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedPostStatus == status ? Color.blue : Color.black , lineWidth: 1)
                        )
                }
            }
        }
        .padding(.trailing, 10)
    }
}

