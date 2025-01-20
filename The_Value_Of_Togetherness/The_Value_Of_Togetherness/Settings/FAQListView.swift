//  FAQListView : 앱에 대한 기본 질문 및 답변

import SwiftUI

// FAQ 구조체 정의
struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// FAQ 리스트 뷰
struct FAQListView: View {
    let faqList = [
        FAQ(question: "Q1. 이 앱은 어떻게 사용하나요?", answer: "이 앱은 사용자 간의 거래를 쉽게 도와주는 앱으로 공구와 나눔으로 카테고리가 나눠집니다."),
        FAQ(question: "Q2. 계정을 어떻게 만들 수 있나요?", answer: "현재 계정 만들기는 자체 앱 계정 만들기만 존재합니다. 추후 카카오톡과 구글 계정을 넣을 계획입니다."),
        FAQ(question: "Q3. 학교를 변경하려면 어떻게 해야 하나요?", answer: "학교 메일을 인증하기 위해 1.회원 탈퇴 후 다시 회원가입을 진행하기 2. 로그아웃 후 다시 회원가입 진행하기 방법이 있습니다."),
        FAQ(question: "Q4. 거래 장소는 확정인가요?", answer: "거래 장소는 게시물 작성자의 희망 거래 장소입니다. 채팅과 댓글을 통해 직접 작성자와 거래 장소, 시간, 결제 등을 상의하실 수 있습니다.")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("자주하는 질문 FAQ")
                        .font(.title)
                        .bold()
                }
                .padding()
                
                List(faqList) { faq in
                    NavigationLink(destination: FAQDetailView(faq: faq)) {
                        Text(faq.question)
                            .font(.headline)
                            .padding(.vertical, 5)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
}

// FAQ 상세 뷰
struct FAQDetailView: View {
    let faq: FAQ
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(faq.question)
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 10)
                
                Text(faq.answer)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
        }
    }
}

// 미리보기
struct FAQListView_Previews: PreviewProvider {
    static var previews: some View {
        FAQListView()
    }
}
