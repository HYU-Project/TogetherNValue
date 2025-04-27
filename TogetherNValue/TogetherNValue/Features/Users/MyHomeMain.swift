// MyHomeMain : 마이페이지, 마이홈 메인 화면

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

func formatDate(_ date: Date?) -> String {
    guard let date = date else { return "날짜 없음" }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yy.MM.dd" // 년도.월.일 형식
    formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일
    return formatter.string(from: date)
}

struct MyHomeMain: View {
    @EnvironmentObject var userManager: UserManager
    @State private var userName: String = ""
    @State private var schoolName: String = ""
    @State private var profileImageURL: URL? // 프로필 이미지 URL
    @State private var createdAt : Date? = nil
    @State private var formattedCreatedAt: String = "날짜 없음"
    
    private var db = Firestore.firestore()
    
    func fetchUserData() {
        guard let userIdx = userManager.userId else {
            print("로그인된 사용자가 없습니다.")
            return
        }
        
        print("Fetching data for userId: \(userIdx)")
        
        db.collection("users").document(userIdx).getDocument { document, error in
            if let error = error {
                print("Firestore에서 사용자 데이터를 가져오는 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                if let userName = data?["name"] as? String,
                   let schoolIdx = data?["school_idx"] as? String {
                    self.userName = userName
                    fetchSchoolName(schoolIdx: schoolIdx)
                } else {
                    print("사용자 데이터를 찾을 수 없습니다. userName 또는 school_idx가 없습니다.")
                }
                
                // profile_image_url 가져오기
                if let profileImageURLString = data?["profile_image_url"] as? String,
                   let url = URL(string: profileImageURLString) {
                    self.profileImageURL = url
                } else {
                    print("profile_image_url이 존재하지 않거나 잘못된 형식입니다.")
                    self.profileImageURL = nil // 기본 이미지를 보여주기 위해 nil로 설정
                }
                
                // createdAt 필드 가져오기
               if let timestamp = data?["createdAt"] as? Timestamp {
                   self.createdAt = timestamp.dateValue() // Timestamp를 Date로 변환
                   self.formattedCreatedAt = formatDate(self.createdAt) // 포맷된 날짜 저장
               } else {
                   print("createdAt 필드가 존재하지 않거나 잘못된 형식입니다.")
                   self.createdAt = nil
                   self.formattedCreatedAt = "날짜 없음"
               }
            } else {
                print("문서가 Firestore에 존재하지 않습니다.")
            }
        }
    }

    func fetchSchoolName(schoolIdx: String) {
        db.collection("schools").document(schoolIdx).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let schoolName = data?["schoolName"] as? String {
                    self.schoolName = schoolName
                } else {
                    print("학교 데이터를 찾을 수 없습니다.")
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
            VStack {
                HStack{
                    Text("마이홈")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                }
                .padding()
                
                    VStack(spacing: 16) {
                        if let profileImageURL = profileImageURL {
                               AsyncImage(url: profileImageURL) { phase in
                                   switch phase {
                                   case .empty:
                                       ProgressView()
                                           .frame(width: 90, height: 90)
                                   case .success(let image):
                                       image
                                           .resizable()
                                           .scaledToFill()
                                           .frame(width: 90, height: 90)
                                           .clipShape(Circle())
                                   case .failure:
                                       Image(systemName: "person.circle.fill")
                                           .resizable()
                                           .frame(width: 90, height: 90)
                                           .foregroundColor(Color.gray)
                                           .clipShape(Circle())
                                   @unknown default:
                                       EmptyView()
                                   }
                               }
                           } else {
                               Image(systemName: "person.circle.fill")
                                   .resizable()
                                   .frame(width: 90, height: 90)
                                   .foregroundColor(Color.gray)
                                   .clipShape(Circle())
                           }
                        
                        Text(userName)
                            .font(.title)
                            .bold()
                        
                        Text(schoolName)
                            .font(.headline)
                        
                        NavigationLink{ UserProfileUpdate()}label:{
                            HStack{
                                Text("프로필 수정")
                                    .font(.headline)
                                    .padding(.horizontal, 20)
                                    .foregroundColor(Color.black)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("나의 거래")
                            .font(.title)
                            .bold()
                            .padding(.trailing, 200)
                        
                        NavigationLink{InterestedPosts().environmentObject(UserManager())
                        }label:{
                            HStack(){
                                Image(systemName:"heart.fill")
                                Text(" 관심 목록")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            .padding(.trailing, 200)
                        }
                        .foregroundStyle(.black)
                        
                        NavigationLink{MyPosts()}label:{
                            HStack(){
                                Image(systemName:"square.and.pencil")
                                Text(" 내가 작성한 게시물")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            .padding(.trailing, 100)
                        }
                        .foregroundStyle(.black)
                        
                        NavigationLink{ParticipateTransactionPosts()}label:{
                            HStack(){
                                Image(systemName:"figure.2")
                                Text("내가 참여한 거래")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            .padding(.trailing, 150)
                        }
                        .foregroundStyle(.black)
                        
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("기타")
                            .font(.title)
                            .bold()
                            .padding(.trailing, 200)
                        
                        NavigationLink(destination: FAQListView()){
                            HStack {
                                Text("자주하는 질문 FAQ")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Color.black)
                                
                                Spacer()
                            }
                            .padding(.trailing, 50)
                        }
                        
                        NavigationLink(destination: TermsOfServiceView()) {
                            HStack {
                                Text("이용약관")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Color.black)
                                
                                Spacer()
                            }
                            .padding(.trailing, 50)
                        }
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Text("개인정보 처리방침")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Color.black)
                                
                                Spacer()
                            }
                            .padding(.trailing, 50)
                        }
                        
                        NavigationLink(destination: AccountInfoView()) {
                            HStack {
                                Text("계정 정보")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Color.black)
                                
                                Spacer()
                                
                                Text("(가입일: \(formattedCreatedAt))")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 50)
                        }
                        
                    }
                    .padding()
                    
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fetchUserData()
        }
    }
    
    
}

#Preview {
    MyHomeMain()
        .environmentObject(UserManager())
}

