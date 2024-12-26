//
//  SearchBarView.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            TextField("Title Search", text: $searchText)
                .padding(.horizontal)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
}

