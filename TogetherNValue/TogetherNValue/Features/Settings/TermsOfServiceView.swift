// 이용약관

import SwiftUI

struct TermsOfServiceView: View {
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                
                Text("이용약관")
                    .font(.title2)
                    .bold()
                    .padding(.leading, 140)
                
                Divider()
                    .padding(.bottom, 10)
                
                Group {
                    Text("제 1조. 목적")
                        .font(.headline)
                    Text("""
                    이 약관은 [같이N가치] (이하 "서비스")가 제공하는 커뮤니티 서비스의 이용과 관련하여, 서비스와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 2조. 용어의 정의")
                        .font(.headline)
                    Text("""
                    1. "이용자"란 본 약관에 따라 서비스를 이용하는 회원을 말합니다.
                    2. "회원"이란 실명 인증 절차를 거쳐 서비스를 이용하는 자를 의미합니다.
                    3. "게시물"이란 회원이 서비스를 이용하며 게시한 글, 이미지, 댓글 등을 의미합니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 3조. 약관의 효력 및 변경")
                        .font(.headline)
                    Text("""
                    1. 본 약관은 서비스를 통해 공지함으로써 효력을 가집니다.
                    2. 서비스는 약관을 변경할 수 있으며, 변경 시 앱 내 공지를 통해 안내합니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 4조. 서비스 제공 및 변경")
                        .font(.headline)
                    Text("""
                    1. 서비스는 연중무휴, 24시간 제공함을 원칙으로 합니다.
                    2. 서비스는 운영상 필요한 경우 서비스의 일부를 수정하거나 중단할 수 있습니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 5조. 회원 가입 및 관리")
                        .font(.headline)
                    Text("""
                    1. 회원 가입은 학교 이메일 및 실명 인증을 통해 이루어집니다.
                    2. 회원은 가입 시 제공한 정보에 대해 책임을 집니다.
                    3. 회원은 언제든지 탈퇴를 요청할 수 있으며, 서비스는 지체 없이 처리합니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 6조. 이용자의 의무")
                        .font(.headline)
                    Text("""
                    1. 이용자는 다음 행위를 해서는 안 됩니다:
                       - 타인의 정보를 도용하는 행위
                       - 서비스 내 불법적, 음란한 정보 게시
                       - 서비스 운영을 방해하는 행위
                    2. 위반 시 서비스는 이용자의 서비스 이용을 제한하거나 탈퇴 처리할 수 있습니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 7조. 게시물 관리")
                        .font(.headline)
                    Text("""
                    1. 이용자가 작성한 게시물의 저작권은 작성자에게 있습니다.
                    2. 서비스는 게시물이 법령 또는 약관에 위반될 경우, 사전 통지 없이 삭제할 수 있습니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 8조. 서비스의 책임")
                        .font(.headline)
                    Text("""
                    1. 서비스는 회원의 귀책사유로 인한 손해에 대해 책임을 지지 않습니다.
                    2. 서비스는 무료로 제공되며, 서비스의 이용과 관련하여 특별한 사정이 없는 한 손해배상 책임을 지지 않습니다.
                    """)
                }
                .padding(.bottom, 15)

                Group {
                    Text("제 9조. 분쟁 해결")
                        .font(.headline)
                    Text("""
                    1. 서비스와 이용자 간 분쟁 발생 시, 상호 협의하여 해결하도록 노력합니다.
                    2. 협의가 되지 않을 경우 민사소송법에 따른 관할 법원에 제소합니다.
                    """)
                }
                .padding(.bottom, 15)

                Text("부칙")
                    .font(.headline)
                Text("본 약관은 2024년 4월 25일부터 시행합니다.")

                Spacer()
               
            }
            .padding()
        }
    }
}

#Preview {
    TermsOfServiceView()
}

