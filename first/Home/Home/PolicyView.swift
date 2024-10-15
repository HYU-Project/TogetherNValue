import SwiftUI

struct PolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("개인정보 처리 방침")
                    .font(.title)
                    .padding(.bottom, 10)
                
                Text("""
                제1조 제1항 ....
                """)
                .padding()
            }
            .padding()
        }
        .navigationTitle("개인정보 처리 방침")
    }
}

struct PolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PolicyView()
    }
}
