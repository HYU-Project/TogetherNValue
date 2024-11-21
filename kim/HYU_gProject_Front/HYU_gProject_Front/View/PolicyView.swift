
//  PolicyView : MyMainHome에서 

import SwiftUI

struct PolicyView: View {
    
    var body: some View {
        VStack {
            HStack{
                Text("이용 약관")
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("""
                    제1조 제1항 
                    ....
                    """)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(width: 300)
                }
            }
        }
        .padding()
    }
}

#Preview {
    PolicyView()
}
