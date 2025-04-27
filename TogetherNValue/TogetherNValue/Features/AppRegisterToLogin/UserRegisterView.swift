// 회원가입 화면
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
    // 이메일&인증코드관련 state
    // 이메일 & 코드 인증 관련 State 추가
    @State private var emailId: String = ""
    //@State private var emailDomain: String = "@gmail.com"
    //@State private var availableDomains = ["@gmail.com", "@naver.com"]

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
                        .font(.system(size: 18, weight: .regular, design: .rounded))
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
                    
                    // 이메일 아이디 + 도메인 선택
                    VStack(spacing: 10) {
                        // 이메일 입력 + 인증하기 버튼 (1줄 구성)
                        HStack(spacing: 5) {
                            TextField("이메일", text: $emailId)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)

                            Button(action: sendVerificationCode) {
                                Text(codeExpired ? "재전송" : "인증하기")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 16)
                                    .background(emailId.isEmpty ? Color.gray.opacity(0.5) : Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(emailId.isEmpty)
                        }
                        .padding(.horizontal)

                        // 인증 코드 입력 + 확인 + 남은 시간
                        if showEmailCodeField {
                            HStack(spacing: 5) {
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

                                if remainingTime > 0 {
                                    Text("\(remainingTime / 60)분 \(remainingTime % 60)초")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                        .bold()
                                        .padding(.leading, 5)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        if !errorMessage2.isEmpty {
                            Text(errorMessage2)
                                .foregroundColor(.red)
                                .font(.footnote)
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
                    
                    // 이용약관
                    HStack{
                        NavigationLink(destination: TermsOfServiceView()) {
                            Text("이용약관동의")
                                .bold()
                                .foregroundColor(.blue)
                                .underline()
                        }
                        
                        Button(action: { isAgreeToTerms.toggle() }) {
                            Image(systemName: isAgreeToTerms ? "checkmark.rectangle.fill" : "rectangle")
                                .foregroundColor(isAgreeToTerms ? .blue : .gray)
                        }
                    }
                    
                }
                
                
                VStack(spacing: 10){
                    // 가입하기 버튼
                    Button(action: register) {
                            Text("가입하기")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(isFormValid ? Color.black : Color.gray)
                                .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(!isFormValid || !isAgreeToTerms)
                    
                    Spacer()
                }
                .padding(.top, 10)
                
                Spacer()
                Spacer()
            }
            .padding()
            .padding(.horizontal,15)
        }
    }
    
    func sendVerificationCode() {
        sentCode = String(Int.random(in: 100000...999999))
        print("인증코드: \(sentCode), 이메일: \(emailId)")
        
        // Info.plist에서 불러온 값 사용
        let smtpHostname: String = Bundle.main.infoDictionary?["SMTP_HOSTNAME"] as? String ?? ""
        let smtpEmail: String = Bundle.main.infoDictionary?["SMTP_EMAIL"] as? String ?? ""
        let smtpPassword: String = Bundle.main.infoDictionary?["SMTP_PASSWORD"] as? String ?? ""

        
        // SMTP로 이메일 전송
        let smtp = SMTP(
            hostname: smtpHostname,
            email: smtpEmail,
            password: smtpPassword,
            port: 465,
            tlsMode: .requireTLS
        )
        let sender = Mail.User(name: "[같이N가치] 인증번호", email: smtpEmail)
        let recipient = Mail.User(name: userName, email: emailId)
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
            userEmail = emailId
        
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
            
            guard !userName.isEmpty, userName.range(of: "^[가-힣a-zA-Z ]{2,}$", options: .regularExpression) != nil else {
                errorMessage = "이름은 2자 이상의 한글 또는 영어만 가능합니다."
                return false
            }
            
            guard !userPhone.isEmpty, userPhone.range(of: "^01[0-9]{8,9}$", options: .regularExpression) != nil else {
                errorMessage = "전화번호 형식이 올바르지 않습니다."
                return false
            }
            
            guard !emailId.isEmpty, emailId.range(of: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", options: .regularExpression) != nil else {
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
