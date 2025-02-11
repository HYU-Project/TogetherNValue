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
                        .frame(width: 100, height: 50)
                        .foregroundColor(selectedPostStatus == status ? .white : .black)
                        .background(selectedPostStatus == status ? Color.black : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
            }
        }
        .padding(.trailing, 10)
    }
}

