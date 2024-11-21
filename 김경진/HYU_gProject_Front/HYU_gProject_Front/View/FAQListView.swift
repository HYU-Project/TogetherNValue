
//  FAQListView : 앱에 대한 기본 질문 및 답변

import SwiftUI

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQListView: View {
    // 예시 FAQ 데이터
    let faqList = [
        FAQ(question: "Q1. 이 앱은 어떻게 사용하나요?", answer: "이 앱은 사용자 간의 거래를 쉽게 도와주는 앱입니다."),
        FAQ(question: "Q2. 계정을 어떻게 만들 수 있나요?", answer: "계정을 만들려면 카카오 또는 구글 계정으로 가입하세요."),
        FAQ(question: "Q3. 매너 온도는 무엇인가요?", answer: "매너 온도는 사용자의 신뢰도를 나타내는 지표입니다.")
    ]
    var body: some View {
        VStack {
            HStack{
                Text("자주하는 질문 FAQ")
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            .padding()
            
            List(faqList) { faq in
                NavigationLink(destination: FAQDetailView(faq: faq)) {
                    Text(faq.question)
                }
            }
        }
        .padding()
    }
}

// FAQ 상세 뷰 (질문과 답변을 보여주는 뷰)
struct FAQDetailView: View {
    let faq: FAQ
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(faq.question)
                .font(.headline)
                .padding(.bottom, 10)
            
            Text(faq.answer)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .navigationTitle("질문")
    }
}

#Preview {
    FAQListView()
}
