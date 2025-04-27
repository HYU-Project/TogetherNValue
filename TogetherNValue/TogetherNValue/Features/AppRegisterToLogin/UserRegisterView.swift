//회원가입 화면
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SwiftSMTP

struct RegisterView: View{
    @State private var userEmail: String = ""
    @State private var userName: String = ""
    @State private var userPhone: String = ""
    @State private var userPwd: String = ""
    @State private var confirmPwd: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading = false
    @State private var isAgreeToTerms = false
    @Environment(\.dismiss) var dismiss // 회원가입 후 로그인 화면으로 돌아가기
    //이메일&인증코드관련 state
    // 이메일 & 코드 인증 관련 State 추가
    @State private var emailId: String = ""
    @State private var emailDomain: String = "@gmail.com"
    @State private var availableDomains = ["@gmail.com", "@naver.com"]

    @State private var showEmailCodeField = false
    @State private var sentCode = ""
    @State private var emailCode = ""
    @State private var isEmailVerified = false

    // 타이머
    @State private var remainingTime: Int = 0
    @State private var timer: Timer?
    @State private var codeExpired = false
    @State private var errorMessage2: String = ""

    
    private var isFormValid: Bool {
        !emailId.isEmpty &&
        !userName.isEmpty &&
        !userPhone.isEmpty &&
        !userPwd.isEmpty &&
        !confirmPwd.isEmpty &&
        isAgreeToTerms &&
        isEmailVerified
       }
    
    var body: some View{
        ZStack{
            Color.skyblue
                .opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 10){
                Spacer()
                Spacer()
                VStack(spacing: 0){
                    Image("logo_3")
                        .resizable()
                        .frame(width:300,height:130)
                        //.padding()
                        .padding(.top, 5)
                    
                    Text("회원가입을 완료해주세요")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .padding()
                }
                
                VStack(spacing: 20){
                    
                    // 이름 입력
                    TextField("이름", text: $userName)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 전화번호 입력
                    TextField("전화번호", text: $userPhone)
                        .keyboardType(.phonePad)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 이메일 입력
//                    TextField("이메일", text: $userEmail)
//                        .keyboardType(.emailAddress)
//                        .padding()
//                        .frame(height: 55) // 높이 조정
//                        .background(Color.white)
//                        .cornerRadius(8)
//                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
//                        .padding(.horizontal)
                    
                    // 이메일 아이디 + 도메인 선택
                    VStack(){
                        
                        HStack(spacing: 3) {
                            TextField("이메일 아이디", text: $emailId)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)

                            Picker(selection: $emailDomain, label: Text(emailDomain).foregroundColor(.black)) {
                                ForEach(availableDomains, id: \.self) { domain in
                                    Text(domain).tag(domain)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 53)
                            .clipped()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                        .frame(height: 50)
                        .padding(.horizontal)
                        
                        // 인증 버튼 - 밑칸으로 이동 & 오른쪽 정렬
                        HStack(spacing:5) {
                            if showEmailCodeField {
                                Spacer()
                                Spacer()
                                TextField("코드 입력", text: $emailCode)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .frame(width: 100)

                                Button(action: verifyEmailCode) {
                                    Text("확인")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.black)
                                        .cornerRadius(8)
                                }
                            }
                            Spacer()
                            Button(action: sendVerificationCode) {
                                Text(codeExpired ? "재전송" : "인증하기")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(emailId.isEmpty ? Color.gray.opacity(0.5) : Color.black.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            //.padding(.trailing)
                            .disabled(emailId.isEmpty)
                        }
                        .padding(.horizontal)
                        
                        VStack{
                            if showEmailCodeField {
                                VStack(alignment: .leading, spacing: 4) {
                                    if remainingTime > 0 {
                                        Text("남은 시간: \(remainingTime / 60)분 \(remainingTime % 60)초")
                                            .foregroundColor(.red)
                                            .font(.footnote)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            if !errorMessage2.isEmpty {
                                Text(errorMessage2)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                        }
                        
                    }
                    
                    
                    // 비밀번호 입력
                    SecureField("비밀번호", text: $userPwd)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 비밀번호 확인 입력
                    SecureField("비밀번호 확인", text: $confirmPwd)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    //이용약관
                    HStack{
                        NavigationLink(destination: ConsentView()) {
                            Text("이용약관동의")
                                //.font(.footnote)
                                .foregroundColor(.red)
                        }
                        Button(action: { isAgreeToTerms.toggle() }) {
                            Image(systemName: isAgreeToTerms ? "checkmark.rectangle.fill" : "rectangle")
                                .foregroundColor(isAgreeToTerms ? .blue : .gray)
                        }
                    }
                    
                    // 오류 메시지
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                
                VStack(spacing: 10){
                    // 가입하기 버튼
                    Button(action: register) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                        } else {
                            Text("가입하기")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isFormValid ? Color.black : Color.gray)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .disabled(!isFormValid || !isAgreeToTerms)
                    
                    Spacer()
                }
                Spacer()
                Spacer()
            }
            .padding()
            .padding(.horizontal,15)
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func sendVerificationCode() {
        let fullEmail = "\(emailId)\(emailDomain)"
        sentCode = String(Int.random(in: 100000...999999))
        print("인증코드: \(sentCode), 이메일: \(fullEmail)")
        
        // SMTP로 이메일 전송
        let smtp = SMTP(
            hostname: "smtp.gmail.com",
            email: "hyvoft@gmail.com",
            password: "hwlzmzphopjngsow",
            port: 465,
            tlsMode: .requireTLS
        )
        let sender = Mail.User(name: "이메일 인증", email: "hyvoft@gmail.com")
        let recipient = Mail.User(name: userName, email: fullEmail)
        let mail = Mail(
            from: sender,
            to: [recipient],
            subject: "회원가입 인증번호",
            text: "인증번호: \(sentCode)\n\n5분 이내에 입력해주세요."
        )
        
        showEmailCodeField = true
        codeExpired = false
        startTimer()
        
        DispatchQueue.global(qos: .background).async {
            smtp.send(mail) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ 이메일 전송 실패: \(error)")
                    } else {
                        print("✅ 이메일 전송 성공")
                        
                    }
                }
            }
        }
    }

    func startTimer() {
        timer?.invalidate()
        remainingTime = 300
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
                sentCode = ""
                showEmailCodeField = false
                isEmailVerified = false
                codeExpired = true
            }
        }
    }

    func verifyEmailCode() {
        if codeExpired {
            errorMessage2 = "인증 시간이 만료되었습니다."
            return
        }
        if emailCode == sentCode {
            isEmailVerified = true
            errorMessage2 = "이메일 인증 성공!"
        } else {
            isEmailVerified = false
            errorMessage2 = "인증번호가 일치하지 않습니다."
        }
    }

    
    func register() {
            // 입력값 검증
            guard isEmailVerified else {
               errorMessage = "이메일 인증을 완료해주세요."
               return
            }
        
            guard validateInputs() else { return }
            
            isLoading = true
            let fullEmail = "\(emailId)\(emailDomain)"
            userEmail = fullEmail
        
            Auth.auth().createUser(withEmail: userEmail, password: userPwd) { result, error in
                isLoading = false
                if let error = error as NSError?, error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    errorMessage = "이미 등록된 이메일입니다."
                } else if let error = error {
                    errorMessage = "회원가입 실패: \(error.localizedDescription)"
                } else if let user = result?.user {
                    saveUserToFirestore(user: user)
                }
            }
        }
        
        func validateInputs() -> Bool {
            errorMessage = ""
            
            let fullEmail = "\(emailId)\(emailDomain)"
            
            guard !userName.isEmpty, userName.range(of: "^[가-힣a-zA-Z ]{2,}$", options: .regularExpression) != nil else {
                errorMessage = "이름은 2자 이상의 한글 또는 영어만 가능합니다."
                return false
            }
            
            guard !userPhone.isEmpty, userPhone.range(of: "^01[0-9]{8,9}$", options: .regularExpression) != nil else {
                errorMessage = "전화번호 형식이 올바르지 않습니다."
                return false
            }
            
            guard !fullEmail.isEmpty, fullEmail.range(of: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", options: .regularExpression) != nil else {
                errorMessage = "이메일 형식이 올바르지 않습니다."
                return false
            }
            
            guard userPwd == confirmPwd else {
                errorMessage = "비밀번호가 일치하지 않습니다."
                return false
            }
            
            guard userPwd.count >= 6 else {
                errorMessage = "비밀번호는 6자 이상이어야 합니다."
                return false
            }
            
            return true
        }
    
    func saveUserToFirestore(user: User){
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData([
            "user_idx": user.uid,
            "email": userEmail,
            "name": userName,
            "phoneNumber": userPhone,
            "profile_image_url": nil,
            "createdAt": Timestamp(),
        ]) { error in
            if let error = error {
                errorMessage = "사용자 데이터 저장 실패: \(error.localizedDescription)"
            } else {
                dismiss() // 성공적으로 저장 후 화면 닫기
            }
        }
    }
}

#Preview{
    RegisterView()
}
