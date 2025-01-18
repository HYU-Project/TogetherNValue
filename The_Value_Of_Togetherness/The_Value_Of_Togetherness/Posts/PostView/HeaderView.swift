//
//  HeaderView.swift
//  HYU_gProject_Front
//
//  Created by 김소민 on 12/25/24.
//

import SwiftUI

struct HeaderView: View {
    var schoolName: String
    var body: some View {
        VStack {
            HStack {
                Text("   \(schoolName)")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
}
