import SwiftUI

struct InfoRegistrationView: View {
    
    @State private var name: String = "홍길동" // 카카오톡 회원가입으로 받아온 이름
    @State private var studentID: String = ""
    @State private var department: String = ""
    @State private var phoneNumber: String = "01012345678" // 카카오톡 회원가입으로 받아온 전화번호
    @State private var email: String = ""
    @State private var emailCode: String = ""
    @State private var isEmailVerified: Bool = false
    @State private var showEmailCodeFields: Bool = false
    @State private var showSchoolPicker: Bool = false
    @State private var selectedSchool: String = ""
    @State private var searchText: String = ""
    
    let schools = [ // 더 추가
        "한양대학교 서울캠",
        "한양대학교 ERICA",
        "서울대학교",
        "연세대학교",
        "고려대학교",
        "경희대학교",
        "성균관대학교",
        "이화여자대학교",
        "부산대학교",
        "충북대학교",
        "전남대학교"
    ]
    
    var sortedSchools: [String] {
            schools.sorted()
        }
    
    var filterSchools: [String] {
        if searchText.isEmpty {
            return sortedSchools
        }
        else {
            return sortedSchools.filter{
                $0.hasPrefix(searchText) // 검색어로 시작하는 학교만 필터링
            }
        }
    }
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            HStack {
                TextField("학교 검색하기", text: $searchText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 70)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                    .onTapGesture {
                        showSchoolPicker = true // 학교 선택 시트 표시
                    }
            }
            .sheet(isPresented: $showSchoolPicker) {
                VStack {
                    List {
                        ForEach(filterSchools , id: \.self ){ school in
                            Button(action: {
                                selectedSchool = school
                                searchText = school
                                showSchoolPicker = false
                            }){
                                Text(school).padding()
                            }
                        }
                    }
                    .navigationTitle("학교 선택")
                    .navigationBarItems(trailing: Button("닫기") {
                        showSchoolPicker = false
                    })
                }
            }.padding()
            
            // 이름 입력
            HStack {
                Text("   이름")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .leading)
                
                TextField("이름", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disabled(true)
            }
            
            // 학번 입력
            HStack {
                Text("*")
                    .font(.title3)
                    .foregroundColor(.red)
                
                Text("학번")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .leading)
                
                TextField("직접입력", text: $studentID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing)
            }
            
            // 학과 입력
            HStack {
                Text("*")
                    .font(.title3)
                    .foregroundColor(.red)
                
                Text("학과")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .leading)
                
                TextField("직접입력", text: $department)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing)
            }
            
            // 전화번호 입력
            HStack {
                Text("  전화번호")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .leading)
                
                TextField(" 전화번호", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disabled(true)
            }
            
            // 학교 이메일
            HStack {
                Text("*")
                    .font(.title3)
                    .foregroundColor(.red)
                
                Text("학교 이메일")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            // 이메일 입력 필드 및 인증 버튼
            HStack {
                TextField("직접 입력", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .padding(.horizontal, 10.0)
                
                Button(action: {
                    // 이메일 형식 유효성 검사
                    if isValidEmail(email){
                        showEmailCodeFields = true
                    } else {
                        // 유저에게 알림 추가
                        print("유효하지 않은 이메일입니다.")
                    }
                    
                }) {
                    Text("인증하기")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 100)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(email.isEmpty)
            }
            .padding(.bottom, 10)
            
            // 이메일 인증 코드 입력
            if showEmailCodeFields {
                HStack {
                    TextField("코드 입력", text: $emailCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                        .padding()
                    
                    HStack(spacing: 10) {
                        Button(action: {
                            // 인증 코드 확인 로직
                        }){
                            Text("확인")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 70)
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // 이메일 인증 코드 재전송 로직
                        }){
                            Text("재전송")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 70)
                                .background(Color.gray)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            Spacer()
            
            // 다음 버튼
            Button(action: {
                // 필수 입력 정보칸 유효성 검사 (학번 10자리, 이메일 인증 true 등)
                // 다음 화면으로 이동하는 로직 추가
            }) {
                Text("다음")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 350)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
        }
        .padding()
    }
    
    
    // 이메일 유효성 검사 함수
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}
#Preview {
    InfoRegistrationView()
}
