//  SignupView.swift : 회원가입 ui
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions
import SwiftSMTP

struct SelectSchoolView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var name: String = "" // 로그인된 user이름
    @State private var phoneNumber: String = "" // 로그인된 user 전화번호
    
    
    // 이메일 & 코드 인증
    @State private var email: String = ""
    @State private var fullEmail: String = "" //사용자 입력과 도메인이 결합된 전체 이메일
    @State private var isEmailVerified: Bool = false
    @State private var showEmailCodeFields: Bool = false
    @State private var emailCode = ""
    @State private var sentCode = ""
    @State private var isCodeValid = false
    
    // 학교 검색
    @State private var showSchoolPicker: Bool = false
    @State private var searchText: String = ""
    @State private var selectedSchool: String = ""
    @State private var selectedSchoolDomain: String = "" // 이메일 도메인
    @State private var selectedSchoolID: String = ""
    
    //타이머 변수
    @State private var remainingTime: Int = 0
    @State private var timer: Timer?
    @State private var codeExpired: Bool = false
    @State private var isButtonActive: Bool = true
    
    @Environment(\.dismiss) var dismiss
    @State private var isContentViewActive = false // 다음화면으로 이동 여부
    
    @State private var isLoggedOut = false // 로그인 상태 체크용
    
    // Firebase Functions 인스턴스 생성
    @State private var functions = Functions.functions()
    // Firestore에서 가져올 학교 리스트
    @State private var schools: [School] = []
    // Firestore 인스턴스 선언
    private var db = Firestore.firestore()
    //firesotre에서 유저 정보 가져옴
    private func fetchUserData(){
        guard let currentUser = Auth.auth().currentUser else{
            print("사용자 로그인되어 있지 않음")
            return
        }
        let userId = currentUser.uid
        db.collection("users").document(userId).getDocument{ document, error in
            if let error = error {
                print("Firestore에서 사용자 데이터를 가져오는 중 오류 발생: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists{
                let data=document.data()
                self.name = data?["name"] as? String ?? "알 수 없음"
                self.phoneNumber = data?["phoneNumber"] as? String ?? "알 수 없음"
            } else{
                print("사용자 정보가 존재하지 않습니다.")
            }
        }
    }
    
    //firestore에서 이메일 정보 가져옴
    private func fetchSchools() {
        db.collection("schools").getDocuments { snapshot, error in
            if let error = error {
                print("학교 데이터를 가져오는 중 오류 발생: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                self.schools = snapshot.documents.map { document in
                    let data = document.data()
                    let schoolID = document.documentID //문서 ID
                    let schoolName = data["schoolName"] as? String ?? ""
                    let schoolDomain = data["schoolDomain"] as? String ?? ""
                    return School(schoolName: schoolName, schoolDomain: schoolDomain, schoolID: schoolID)
                }
            }
        }
    }

    var filteredSchools: [School] {
        let sortedSchools = schools.sorted { $0.schoolName < $1.schoolName }
        return searchText.isEmpty ? sortedSchools : sortedSchools.filter { $0.schoolName.contains(searchText) }
    }
    
    var body: some View {
        
            NavigationView {
            
                VStack(spacing: 15) {
                    
                    HStack {
                        Button(action: {
                            showSchoolPicker = true
                        }){
                            HStack {
                                Image(systemName: "building.columns")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                                
                                Text(selectedSchool.isEmpty ? "학교 선택하기" : selectedSchool)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 3))
                            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)

                            
                        }
                        .sheet(isPresented: $showSchoolPicker){
                            VStack{
                                TextField("학교 검색", text: $searchText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                
                                List(filteredSchools, id: \.schoolName){
                                    school in
                                    Button(action: {
                                        selectedSchool = school.schoolName
                                        selectedSchoolDomain = school.schoolDomain
                                        selectedSchoolID = school.schoolID
                                        showSchoolPicker = false
                                        // 이메일, 인증 코드, 타이머 초기화
                                        email = ""
                                        fullEmail = ""
                                        emailCode = ""
                                        sentCode = ""
                                        isEmailVerified = false
                                        showEmailCodeFields = false
                                        codeExpired = false
                                        isButtonActive = true
                                        timer?.invalidate()
                                        remainingTime = 0
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
                    
                    VStack(spacing: 15){
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
                        .frame(height: 45)
                        
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
                        .frame(height: 45)
                    }
                    .onAppear{
                        fetchUserData() //Firestore에서 데이터 가져오기
                        fetchSchools()
                    }
                    .padding()
                    
                    
                    // 학교 이메일
                    HStack {
                        Text(" *")
                            .font(.title3)
                            .foregroundColor(.red)
                        
                        Text(" 학교 이메일")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    // 이메일 입력 필드 및 인증 버튼
                    
                    HStack(spacing: 5) {
                        HStack(spacing: 0) {
                            // 사용자가 입력하는 이메일 아이디 부분
                            TextField("이메일 아이디", text: $email)
                                .padding()
                                .frame(maxWidth: .infinity)
                            
                            // 고정된 이메일 도메인
                            Text("\(selectedSchoolDomain.isEmpty ? "" : selectedSchoolDomain)")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 2))
                        .disabled(selectedSchoolDomain.isEmpty) // 학교를 선택하지 않았다면 입력 불가능
                        .frame(width: 255)
                        
                        Button(action: sendVerificationCode) {
                            Text(codeExpired ? "재전송" : "인증")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding()
                                .frame(width: codeExpired ? 65 : 65)
                                .frame(height: 45)
                                .background(isButtonActive ? Color.black : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        .disabled(email.isEmpty || selectedSchoolDomain.isEmpty || !isButtonActive)
                    }
                    .padding(.leading, 15)
                
                    // 이메일 인증 코드 입력
                    if showEmailCodeFields {
                        VStack(alignment: .leading, spacing: 5) {
                               HStack(spacing: 10) {
                                   TextField("코드 입력", text: $emailCode)
                                       .padding()
                                       .frame(width: 150, height: 45)
                                       .cornerRadius(8)
                                       .background(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 2))

                                   Button(action: verifyEmailCode) {
                                       Text("확인")
                                           .font(.caption)
                                           .foregroundColor(.white)
                                           .frame(width: 60, height: 45)
                                           .background(Color.black)
                                           .cornerRadius(8)
                                   }

                                   if remainingTime > 0 {
                                       Text("\(remainingTime / 60)분 \(remainingTime % 60)초")
                                           .foregroundColor(.red)
                                           .font(.footnote)
                                           .bold()
                                   }
                               }
                               .padding(.trailing, 60)

                           }
                           .padding(.top, 5)
                    }
                    
                    Spacer()
                    
                    
                    NavigationLink(destination: ContentView()
                        .navigationBarBackButtonHidden(true),
                                   isActive: $isContentViewActive){
                        Button(action: saveUserDataAndContinue) {
                            Text("다음")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .frame(width: 350)
                                .frame(height: 70)
                                .background(isFormValid ? Color.blue: Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                    }
                                   .padding(.top, 20)
                    NavigationLink(destination: LoginView()
                        .navigationBarBackButtonHidden(true),
                                   isActive: $isLoggedOut) {
                        EmptyView()
                    }
                }
                .padding()
                .onAppear {
                    checkLoginStatus()
                    if !isLoggedOut {
                        fetchUserData()
                        fetchSchools()
                    }
                }
            }
            .navigationBarHidden(true)
    }
    
    private func checkLoginStatus() {
        if Auth.auth().currentUser == nil {
            print("로그인 안 됨 → LoginView로 이동")
            isLoggedOut = true
        } else {
            isLoggedOut = false
        }
    }
    
    private func sendVerificationCode(){
        fullEmail = "\(email)\(selectedSchoolDomain)"
        sentCode = String(Int.random(in: 100000...999999)) // 인증 코드 생성
        print("인증 코드 전송: \(sentCode) (이메일: \(fullEmail))")
        
        // Info.plist에서 불러온 값 사용
        let smtpHostname: String = Bundle.main.infoDictionary?["SMTP_HOSTNAME"] as? String ?? ""
        let smtpEmail: String = Bundle.main.infoDictionary?["SMTP_EMAIL"] as? String ?? ""
        let smtpPassword: String = Bundle.main.infoDictionary?["SMTP_PASSWORD"] as? String ?? ""

        
        showEmailCodeFields = true
        codeExpired = false
        isButtonActive = false

        let smtp = SMTP(
            hostname: smtpHostname,
            email: smtpEmail,
            password: smtpPassword,
            port: 465,
            tlsMode: .requireTLS
        )
        let sender = Mail.User(name: "[같이N가치] 학교 인증코드", email: smtpEmail)
        let recipient = Mail.User(name: name , email: fullEmail)
        let mail = Mail(
            from: sender,
            to: [recipient],
            subject: "학교 이메일 인증코드",
            text: "인증코드: \(sentCode)\n\n5분 이내에 입력해주세요."
        )
        
        DispatchQueue.global(qos: .background).async {
            smtp.send(mail) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ 이메일 인증번호 전송 실패: \(error)")
                        showEmailCodeFields = false
                        codeExpired = true
                        isButtonActive = true
                    } else {
                        print("✅ 이메일 인증번호 전송 성공")
                    }
                }
            }
        }

        timer?.invalidate()
        remainingTime = 300
        timer = Timer.scheduledTimer(withTimeInterval :1.0, repeats: true){ _ in
            if remainingTime > 0{
                remainingTime -= 1
            }else{
                timer?.invalidate()
                print("인증시간 만료")
                sentCode = ""
                showEmailCodeFields = false
                isEmailVerified = false
                codeExpired = true
                isButtonActive = true
            }
        }
    }
    
    
    private func verifyEmailCode() {
        if codeExpired{
            print("코드 인증 실패. 유효시간 지남")
            return
        }
        if emailCode == sentCode {
            isEmailVerified = true
            print("이메일 인증 성공")
        } else {
            isEmailVerified = false
            print("인증 코드가 일치하지 않습니다.")
        }
    }
    
    private func saveUserDataAndContinue() {
            guard let currentUser = Auth.auth().currentUser else {
                print("현재 사용자 정보가 없습니다. 로그인 세션이 만료되었을 수 있습니다.")
                return
            }
            let userId = currentUser.uid
            
            db.collection("users").document(userId).updateData([
                "schoolEmail": fullEmail,
                "school_idx": selectedSchoolID
            ]) { error in
                if let error = error {
                    print("사용자 정보 업데이트 실패: \(error.localizedDescription)")
                } else {
                    print("사용자 정보 업데이트 성공")
                    userManager.userId = userId // 상태 갱신
                    DispatchQueue.main.async {
                        isContentViewActive = true
                    }
                }
            }
        }
    
    
    // 폼 인증 검사
    private var isFormValid: Bool {
        return !email.isEmpty && isEmailVerified && !selectedSchool.isEmpty
    }
}

struct School{
    let schoolName: String // 학교 이름
    let schoolDomain: String // 학교 이메일 도메인
    let schoolID: String //Firestore 문서 ID
}

#Preview {
    SelectSchoolView()
        .environmentObject(UserManager())
}
