//
//  CategoryButtonsView.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import SwiftUI

struct CategoryButtonsView: View {
    @Binding var selectedCategory: String
    var body: some View {
        HStack(spacing: 30) {
            ForEach(["식재료", "물품", "배달"], id: \.self) { category in
                Button(action: {
                    selectedCategory = selectedCategory == category ? "" : category
                }) {
                    Text(category)
                        .frame(width: 80, height: 50)
                        .foregroundColor(selectedCategory == category ? .white : .black)
                        .background(selectedCategory == category ? Color.black : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                .padding(.horizontal, 5)
            }
        }
        .padding()
    }
}
