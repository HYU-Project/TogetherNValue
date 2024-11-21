
//  ConsentView.swift : 개인정보 동의 ui

import SwiftUI

struct ConsentView: View {
    @State private var agreeTerms: Bool = true
    @State private var agreePrivacy: Bool = true
    @State private var agreeAge: Bool = true
    @State private var allAgreed: Bool = true // 기본값을 true로 설정
    
    var body: some View {
        NavigationView { // NavigationView 추가
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    
                    Text("서비스 이용을 위한 필수 동의 항목")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 10.0)
                    
                    AgreementRow(
                        title : "이용 약관 동의",
                        isAgreed : $agreeTerms,
                        onDetailTapped: {
                            // 개인정보 보호방침 상세 보기 화면으로 이동
                        }
                    )
                    
                    AgreementRow(
                        title: "개인정보 보호방침 동의",
                        isAgreed : $agreePrivacy,
                        onDetailTapped : {
                            
                        }
                    )
                    
                    AgreementRow(
                        title: "만 14세 이상입니다",
                        isAgreed: $agreeAge,
                        onDetailTapped: nil
                    )
                    
                    // NavigationLink 추가하여 다음 화면으로 이동
                    NavigationLink(destination: SignupView()) {
                        Text("네, 모두 동의해요")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: 350)
                            .foregroundColor(.white)
                            .background( Color.black )
                            .cornerRadius(8)
                    }
                    .disabled(!(agreeTerms && agreePrivacy && agreeAge)) // 모든 항목이 동의되어야 활성화
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
            }
            .padding()
        }
    }
}

// AgreementRow 구조체는 수정할 필요가 없습니다.
struct AgreementRow : View {
    var title: String
    @Binding var isAgreed: Bool
    var onDetailTapped: (() -> Void)?
    
    var body: some View {
        HStack {
            Button(action: {
                isAgreed.toggle()
            }) {
                Image(systemName: isAgreed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isAgreed ? .black : .gray)
                    .font(.system(size: 30))
            }
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.leading, 4.0)
            
            Spacer()
            
            if onDetailTapped != nil {
                Button(action: {
                    onDetailTapped?()
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.all, 17.0)
    }
}

#Preview {
    ConsentView()
}
