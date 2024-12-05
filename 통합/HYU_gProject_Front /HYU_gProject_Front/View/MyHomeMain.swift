

// MyHomeMain : 마이페이지, 마이홈 메인 화면

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


// Users에서 school_idx, profile_image_url, userName 가져오기
// Schools에서 Users 테이블에 저장된 schoolIdx를 통해 가져오기
// 프로필 이미지 url을 통해 storage에 저장된 실제 이미지 가져오기 (미완료)
    
struct MyHomeMain: View {
    
    @State private var userName: String = ""
    @State private var schoolName: String = ""
    
    @State private var userProfile = Users(user_idx: 1, userName: "김무명", user_phoneNum: "010-1234-5678", school_idx: 1, user_schoolEmail: "", profile_image_url: "https://example.com/profile-image.jpg", created_at:"")
    
    @State private var schoolInfo = Schools(school_idx: "", schoolName: "한양대학교 서울캠", schoolEmail: "@hanyang.ac.kr")
    
    private var db = Firestore.firestore()
    
    private var stoarge = Storage.storage()
    
    // 로그인한 사용자의 UID 반환
    func getCurrentUserId() -> String?{
        if let user = Auth.auth().currentUser{
            return user.uid
        }
        else {
            print("로그인한 유저 없음")
            return nil
        }
    }
    
    func fetchUserData(){
        guard let userIdx = getCurrentUserId() else {
                    print("로그인된 사용자가 없습니다.")
                    return
                }
        
        db.collection("Users").document(userIdx).getDocument{ document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let userName = data?["userName"] as? String,
                   let profile_image_url = data?["profile_image_url"] as? String,
                   let school_idx = data?["school_idx"] as? String {
                    
                    self.userName = userName
                    // storage에서 user의 프로필 이미지 PNG, JPG 가져오기
                    
                    
                    fetchSchoolName(schoolIdx: school_idx)
                }
                else {
                    print("사용자 데이터를 찾을 수 없습니다.")
                }
                    
            }
            
        }
    }
    
    func fetchSchoolName(schoolIdx: String){
        db.collection("Schools").document(schoolIdx).getDocument{
            document, error in
            if let document = document, document.exists{
                let data = document.data()
                if let schoolName = data?["schoolName"] as? String{
                    self.schoolName = schoolName
                }
                else {
                    print("학교 데이터를 찾을 수 없습니다.")
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack{
                    Text("마이홈")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                }
                .padding()
                
                ScrollView{
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        
                        Text(userProfile.userName)
                            .font(.title)
                            .bold()
                        
                        Text(schoolInfo.schoolName)
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
                            .font(.title2)
                            .bold()
                            .padding(.trailing, 200)
                        
                        NavigationLink{InterestedPosts()}label:{
                            HStack(){
                                Image(systemName:"heart")
                                Text("관심 목록")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            .padding(.trailing, 200)
                        }
                        .foregroundStyle(.black)
                        
                        NavigationLink{MyPosts()}label:{
                            HStack(){
                                Image(systemName:"pencil")
                                Text("내가 작성한 게시글")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            .padding(.trailing, 100)
                        }
                        .foregroundStyle(.black)
                        
                        NavigationLink{ParticipateTransactionPosts()}label:{
                            HStack(){
                                Image(systemName:"hand.raised")
                                Text("참여한 거래")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                            }
                            .padding(.trailing, 200)
                        }
                        .foregroundStyle(.black)
                        
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("기타")
                            .font(.title2)
                            .bold()
                            .padding(.trailing, 200)
                        
                        NavigationLink(destination: PolicyView()) {
                            HStack {
                                Text("이용약관 (개인 정보 처리 방침)")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Color.black)
                                
                                Spacer()
                            }
                            .padding(.trailing, 50)
                        }
                        
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
                        
                        NavigationLink(destination: AccountInfoView()) {
                            HStack {
                                Text("계정 정보")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Color.black)
                                
                                Spacer()
                                
                                Text("카카오 (가입일: 2024.9.7)")
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
        }
    }
}

#Preview {
    MyHomeMain()
}
