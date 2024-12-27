//로그인 화면
import SwiftUI
import FirebaseAuth
import Firebase

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @State private var isNavigatingToContentView = false
    @State private var isNavigatingToSelectSchoolView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.skyblue
                    .opacity(0.8)
                    .ignoresSafeArea()
                       
                VStack(alignment: .center, spacing: 60) {
                    Spacer()
                    VStack(spacing: 0) {
                        Image("logo_2")
                            .resizable()
                            .frame(width:300,height:120)
                            .padding()
                        
                        Text("서비스 이용을 위해 로그인 해주세요")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .padding(.top, 10)
                    }
                        
                    VStack(spacing: 25) {
                        // 이메일과 비밀번호 입력 필드
                        TextField("이메일", text: $email)
                            .padding()
                            .frame(height: 60)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                            .padding(.horizontal)
                            
                        ZStack {
                            if showPassword {
                                TextField("비밀번호", text: $password)
                                    .padding()
                                    .frame(height: 60)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                                    .padding(.horizontal)
                            } else {
                                SecureField("비밀번호", text: $password)
                                    .padding()
                                    .frame(height: 60)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 0, y: 2)
                                    .padding(.horizontal)
                            }
                                   
                            HStack {
                                Spacer()
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 20)
                                }
                            }
                        }
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .frame(height: 20)
                    }
                           
                    VStack(spacing: 10) {
                        Button(action: login) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(1))
                                    .cornerRadius(8)
                            } else {
                                Text("로그인")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(1))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                            
                        }
                        .disabled(isLoading)
                               
                        NavigationLink(destination: RegisterView()) {
                            Text("계정이 없으신가요? 회원가입")
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Navigation to ContentView or UserRegisterView
                NavigationLink(
                    destination: ContentView(),
                    isActive: $isNavigatingToContentView,
                    label: { EmptyView() }
                )
                
                NavigationLink(
                    destination: SelectSchoolView(),
                    isActive: $isNavigatingToSelectSchoolView,
                    label: { EmptyView() }
                )
            }
        }
        .navigationTitle("")
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "모든 필드를 입력하세요."
            return
        }
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .wrongPassword:
                        errorMessage = "비밀번호가 잘못되었습니다."
                    case .userNotFound:
                        errorMessage = "해당 사용자가 존재하지 않습니다."
                    case .invalidEmail:
                        errorMessage = "이메일 형식이 올바르지 않습니다."
                    default:
                        errorMessage = "로그인 실패: \(error.localizedDescription)"
                    }
                } else if let user = result?.user {
                    self.checkSchoolEmail(for: user.uid)
                }
            }
        }
    }
    
    private func checkSchoolEmail(for userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Firestore에서 사용자 데이터 확인 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let schoolEmail = document.data()?["schoolEmail"] as? String
                DispatchQueue.main.async {
                    if let schoolEmail = schoolEmail, !schoolEmail.isEmpty {
                        self.isNavigatingToContentView = true
                    } else {
                        self.isNavigatingToSelectSchoolView = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isNavigatingToSelectSchoolView = true
                }
            }
        }
    }
}



#Preview {
    LoginView()
}
