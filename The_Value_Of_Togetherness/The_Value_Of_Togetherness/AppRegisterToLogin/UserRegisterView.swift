//회원가입 화면
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
    
    private var isFormValid: Bool {
           !userEmail.isEmpty &&
           !userName.isEmpty &&
           !userPhone.isEmpty &&
           !userPwd.isEmpty &&
           !confirmPwd.isEmpty &&
           isAgreeToTerms
       }
    
    var body: some View{
        ZStack{
            Color.skyblue
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 20){
                Spacer()
                Spacer()
                VStack(spacing: 0){
                    Image("logo_2")
                        .resizable()
                        .frame(width:280,height:100)
                        .padding()
                        .padding(.top, 20)
                    
                    Text("회원가입을 완료해주세요")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .padding(.top, 5)
                }
                
                VStack(spacing: 25){
                    
                    // 이름 입력
                    TextField("이름", text: $userName)
                        .padding()
                        .frame(height: 55) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 전화번호 입력
                    TextField("전화번호", text: $userPhone)
                        .keyboardType(.phonePad)
                        .padding()
                        .frame(height: 55) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 이메일 입력
                    TextField("이메일", text: $userEmail)
                        .keyboardType(.emailAddress)
                        .padding()
                        .frame(height: 55) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 비밀번호 입력
                    SecureField("비밀번호", text: $userPwd)
                        .padding()
                        .frame(height: 55) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 비밀번호 확인 입력
                    SecureField("비밀번호 확인", text: $confirmPwd)
                        .padding()
                        .frame(height: 55) // 높이 조정
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
    
    func register() {
            // 입력값 검증
            guard validateInputs() else { return }
            
            isLoading = true
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
            
            guard !userEmail.isEmpty, userEmail.range(of: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", options: .regularExpression) != nil else {
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

