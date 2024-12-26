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
    @Environment(\.dismiss) var dismiss // 회원가입 후 로그인 화면으로 돌아가기
    
    var body: some View{
        ZStack{
            Color.blue
                .opacity(0.1)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 60){
                Spacer()
                
                VStack(spacing: 0){
                    Text("같이의 가치")
                        .font(.system(size: 30, weight: .bold, design:.rounded))
                    Text("회원가입을 완료해주세요")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .padding(.top, 10)
                }
                
                VStack(spacing: 25){
                    
                    // 이름 입력
                    TextField("이름", text: $userName)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 전화번호 입력
                    TextField("전화번호", text: $userPhone)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 이메일 입력
                    TextField("이메일", text: $userEmail)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 비밀번호 입력
                    SecureField("비밀번호", text: $userPwd)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    // 비밀번호 확인 입력
                    SecureField("비밀번호 확인", text: $confirmPwd)
                        .padding()
                        .frame(height: 50) // 높이 조정
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                    
                    //이용약관
                    NavigationLink(destination: ConsentView()) {
                        Text("이용약관동의")
                            .font(.footnote)
                            .foregroundColor(.blue)
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
                                .background(Color.yellow.opacity(0.8))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .disabled(isLoading) // 로딩 중 버튼 비활성화
                    
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
    
    func register(){
        guard !userEmail.isEmpty, !userPwd.isEmpty, !confirmPwd.isEmpty else {
            errorMessage = "모든 필드를 입력하세요."
            return
        }

        guard userPwd == confirmPwd else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }

        guard userPwd.count >= 6 else {
            errorMessage = "비밀번호는 6자 이상이어야 합니다."
            return
        }
        isLoading = true
        Auth.auth().createUser(withEmail: userEmail, password: userPwd) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = "회원가입 실패: \(error.localizedDescription)"
            } else if let user = result?.user {
                saveUserToFirestore(user: user)
            }
        }
    }
    
    func saveUserToFirestore(user: User){
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData([
            "email": userEmail,
            "name": userName,
            "phoneNumber": userPhone,
            "createdAt": Timestamp()
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
