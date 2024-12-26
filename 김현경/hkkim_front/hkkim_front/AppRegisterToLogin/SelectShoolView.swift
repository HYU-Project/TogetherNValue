//  SignupView.swift : 회원가입 ui
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

struct SelectSchoolView: View {
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
    @State private var selectedSchool: String = ""
    @State private var searchText: String = ""
    @State private var selectedSchoolEmail: String = "" // 이메일 도메인
    
    @Environment(\.dismiss) var dismiss
    @State private var isContentViewActive = false // 다음화면으로 이동 여부
    
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
                    let schoolName = data["schoolName"] as? String ?? ""
                    let schoolEmail = data["schoolEmail"] as? String ?? ""
                    return School(schoolName: schoolName, schoolEmail: schoolEmail)
                }
            }
        }
    }

    var filteredSchools: [School] {
        let sortedSchools = schools.sorted { $0.schoolName < $1.schoolName }
        return searchText.isEmpty ? sortedSchools : sortedSchools.filter { $0.schoolName.contains(searchText) }
    }
    
    var body: some View {
        NavigationView{
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
                            
                            List(filteredSchools, id: \.schoolName){
                                school in
                                Button(action: {
                                    selectedSchool = school.schoolName
                                    selectedSchoolEmail = school.schoolEmail
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
                }
                .onAppear{
                    fetchUserData() //Firestore에서 데이터 가져오기
                    fetchSchools()
                }
                .padding()
                
                
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
                VStack {
                    HStack(spacing: 0) {
                            // 사용자가 입력하는 이메일 아이디 부분
                            TextField("이메일 아이디", text: $email)
                                .padding()
                                .frame(maxWidth: .infinity)

                            // 고정된 이메일 도메인
                            Text("\(selectedSchoolEmail.isEmpty ? "" : selectedSchoolEmail)")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 2))
                        .disabled(selectedSchoolEmail.isEmpty) // 학교를 선택하지 않았다면 입력 불가능
                        .frame(width: 300)
                    
                    Button(action: sendVerificationCode) {
                        Text("인증하기")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: 100)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(email.isEmpty || selectedSchoolEmail.isEmpty)
                   
                }
                .padding(.bottom, 10)
                
                // 이메일 인증 코드 입력
                if showEmailCodeFields {
                    HStack {
                        TextField("코드 입력", text: $emailCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                            .padding()
                        Button(action: verifyEmailCode){
                            Text("확인")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 70)
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                    }
                }
                Spacer()
                
                NavigationLink(destination: ContentView(), isActive: $isContentViewActive){
                    Button(action: saveUserDataAndContinue) {
                        Text("다음")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: 350)
                            .background(isFormValid ? Color.black: Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }        
    
    private func sendVerificationCode(){
        //guard !email.isEmpty, !selectedSchoolEmail.isEmpty else { return }
        fullEmail = "\(email)\(selectedSchoolEmail)"
        sentCode = String(Int.random(in: 100000...999999)) // 인증 코드 생성
        print("인증 코드 전송: \(sentCode) (이메일: \(fullEmail))")

        
        // Firebase Functions 호출
        ///unctions.httpsCallable("sendVerificationEmail").call(["email": fullEmail, "code": sentCode]) { result, error in
            //if let error = error {
                //print("이메일 전송 실패: \(error.localizedDescription)")
                //return
            //}
            //print("이메일 전송 성공: \(result?.data ?? "No data")")
            showEmailCodeFields = true
        //}
    }
    
    private func verifyEmailCode() {
            if emailCode == sentCode {
                isEmailVerified = true
                print("이메일 인증 성공")
            } else {
                isEmailVerified = false
                print("인증 코드가 일치하지 않습니다.")
            }
        }
    
    private func saveUserDataAndContinue() {
            guard let currentUser = Auth.auth().currentUser else { return }
            let userId = currentUser.uid
            
            db.collection("users").document(userId).updateData([
                "schoolEmail": fullEmail
            ]) { error in
                if let error = error {
                    print("사용자 정보 업데이트 실패: \(error.localizedDescription)")
                } else {
                    print("사용자 정보 업데이트 성공")
                    isContentViewActive = true
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
    let schoolEmail: String // 학교 이메일
}

#Preview {
    SelectSchoolView()
}
