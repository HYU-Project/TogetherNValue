
import SwiftUI

struct AccountDeletionConfirmationView: View {
    @EnvironmentObject var userManager: UserManager
    var body: some View {
        ZStack{
            
            Color.skyblue
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Text("정말 탈퇴하시겠습니까?")
                    .font(.title)
                    .bold()
                    .padding()
                
                // 앱 사진 슬라이드 쇼
                FeatureSlideshowView()
                    .padding(.bottom, 20)
                
                Text("탈퇴 후에는\n모든 데이터가 삭제되며 복구할 수 없습니다.")
                    .font(.body)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    
                }){
                    Text("다음")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.black)
                        .frame(width: 280, height: 40)
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct FeatureSlideshowView: View {
    @State private var currentIndex = 0
    private let images = ["feature1", "feature2", "feature3"]
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300) // 슬라이드 쇼 높이
        .onAppear {
            startAutoSlide()
        }
    }
    
    private func startAutoSlide() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            currentIndex = (currentIndex + 1) % images.count
        }
    }
}

#Preview {
    AccountDeletionConfirmationView()
}
