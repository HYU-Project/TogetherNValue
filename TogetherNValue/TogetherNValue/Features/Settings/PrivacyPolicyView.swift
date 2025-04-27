// 개인정보 처리방침

import SwiftUI

struct PrivacyPolicyView: View {
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                
                Text("개인정보 처리방침")
                    .font(.title2)
                    .bold()
                    .padding(.leading, 120)
                
                Divider()
                    .padding(.bottom, 10)
                
                Group {
                   Text("제 1조. 수집하는 개인정보 항목")
                       .font(.headline)
                   Text("""
                   당 서비스는 회원가입 및 서비스 이용을 위해 다음과 같은 개인정보를 수집합니다:
                   - 이름
                   - 이메일 주소
                   - 전화번호
                   """)
                    
               }
                .padding(.bottom, 15)
                
                Group {
                    Text("제 2조. 개인정보 수집 및 이용 목적")
                        .font(.headline)
                    Text("""
                    수집된 개인정보는 다음의 목적을 위해 사용됩니다:
                    1. 회원 가입 및 로그인 기능 제공
                    2. 커뮤니티 내 서비스 이용을 위한 본인 확인
                    3. 마케팅 및 이벤트 안내
                    4. 서비스 이용 통계 분석 및 개선
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 3조. 개인정보 보유 및 이용 기간")
                        .font(.headline)
                    Text("""
                    회원의 개인정보는 회원 탈퇴 시까지 보유 및 이용됩니다.
                    관계 법령에 따라 보존이 필요한 경우, 해당 법령에서 정한 기간 동안 보존될 수 있습니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 4조. 개인정보 처리 위탁")
                        .font(.headline)
                    Text("""
                    당 서비스는 원활한 서비스 제공을 위해 다음과 같이 개인정보 처리를 외부에 위탁하고 있습니다:
                    - 위탁 대상자: Google Firebase
                    - 위탁 업무 내용: 데이터 저장, 인증 및 알림 서비스 제공
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 5조. 이용자의 권리 및 행사 방법")
                        .font(.headline)
                    Text("""
                    이용자는 언제든지 본인의 개인정보에 대해 열람, 수정, 삭제 요청을 할 수 있습니다.
                    요청은 hyvoft@gmail.com을 통해 가능하며, 본인 확인 후 지체 없이 처리됩니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 6조. 개인정보 보호 책임자")
                        .font(.headline)
                    Text("""
                    이름: 같이N가치
                    이메일: hyvoft@gmail.com
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 7조. 개인정보 처리방침 변경")
                        .font(.headline)
                    Text("""
                    본 개인정보 처리방침은 법령 또는 서비스 정책 변경에 따라 수정될 수 있으며, 변경 시 앱 내 공지를 통해 안내드립니다.
                    """)
                }
                .padding(.bottom, 15)

                Text("최종 수정일: 2024년 4월 25일")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    PrivacyPolicyView()
}

