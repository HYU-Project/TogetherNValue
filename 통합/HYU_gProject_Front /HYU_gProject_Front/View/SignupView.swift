
//  SignupView.swift : 회원가입 ui

import SwiftUI
import FirebaseFirestore

struct SignupView: View {
    @State private var name: String = "홍길동" // 카카오톡 회원가입으로 받아온 이름
    @State private var phoneNumber: String = "01012345678" // 카카오톡 회원가입으로 받아온 전화번호
    
    // 이메일 & 코드 인증
    @State private var email: String = ""
    @State private var isEmailVerified: Bool = false
    @State private var showEmailCodeFields: Bool = false
    @State private var emailCode = ""
    @State private var verificationCode = ""
    @State private var sentCode = ""
    @State private var isCodeSent = false
    @State private var isCodeValid = false
    
    // 학교 검색
    @State private var showSchoolPicker: Bool = false
    @State private var selectedSchool: String = ""
    @State private var searchText: String = ""
    
    // Firestore에서 가져올 학교 리스트
    @State private var schools: [Schools] = []
    // Firestore 인스턴스 선언
    private var db = Firestore.firestore()
    
    func fetchSchools() {
        db.collection("Schools").getDocuments { (snapshot, error) in
            if let error = error {
                print("Schools data fetch Error: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                DispatchQueue.main.async {
                    self.schools = snapshot.documents.map { document in
                        let data = document.data()
                        let school_idx = document.documentID
                        let schoolName = data["schoolName"] as? String ?? ""
                        let schoolEmail = data["schoolEmail"] as? String ?? ""
                        return Schools(school_idx: school_idx, schoolName: schoolName, schoolEmail: schoolEmail)
                    }
                }
            }
        }
    }
    
    var filteredSchools: [Schools] {
        if searchText.isEmpty{
            return schools
        }
        else {
            return schools.filter{$0.schoolName.contains(searchText)}
        }
    }
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            HStack {
                Button(action: {
                    showSchoolPicker = true
                }){
                    Text(selectedSchool.isEmpty ? "학교를 선택하세요" : selectedSchool)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(height: 50)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showSchoolPicker){
                    VStack{
                        TextField("학교 검색", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        List(filteredSchools, id: \.school_idx){
                            school in
                            Button(action: {
                                selectedSchool = school.schoolName
                                showSchoolPicker = false
                            }){
                                Text(school.schoolName)
                                    .foregroundColor(.black)
                                    .fontWeight(.medium)
                            }
                            .listRowBackground(Color.white)
                        }
                        .background(Color.white)
                        .foregroundColor(.black)
                    }
                    .padding()
                }
            }
            .padding()
            
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
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 2))
                    .frame(width: 200)
                
                Button(action: {
                    // 이메일 형식 유효성 검사
                    if isValidEmail(email){
                        sentCode = createEmailCode() // 인증 코드 생성
                        sendVerificationEmail(userEmail: email, certiCode: sentCode) // 이메일 전송
                        showEmailCodeFields = true
                        isCodeSent = true
                        print("이메일이 전송되었습니다.")
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
                            // 인증 코드 확인
                            if emailCode == sentCode {
                                isEmailVerified = true
                                isCodeValid = true
                                print("이메일 인증 성공")
                            }
                            else{
                                isEmailVerified = false
                                print("인증 코드가 틀렸습니다.")
                            }
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
                            sentCode = createEmailCode()
                            sendVerificationEmail(userEmail: email, certiCode: sentCode)
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
            
            Button(action: {
                // 폼 유효성 검사
                if isFormValid {
                    // 다음 버튼
                }
                else {
                
                }
            }) {
                Text("다음")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 350)
                    .background(isFormValid ? Color.black: Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(!isFormValid)
            
        }
        .onAppear {
            fetchSchools()  // 뷰가 나타날 때 데이터 로드 시작
        }
        .padding()
    }
    
    
    // 이메일 유효성 검사 함수
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    // 폼 인증 검사
    private var isFormValid: Bool {
        return !email.isEmpty && isEmailVerified && !selectedSchool.isEmpty
    }
}


#Preview {
    SignupView()
}
