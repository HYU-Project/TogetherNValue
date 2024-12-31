// MyHomeMain : 마이페이지, 마이홈 메인 화면

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

// Users에서 school_idx, profile_image_url, userName 가져와서 뿌리기
// Schools에서 Users 테이블에 저장된 schoolIdx를 통해 가져오기
// 일단 이미지 가져오는 것은 나중에
// 프로필 이미지 url을 통해 storage에 저장된 실제 이미지 가져오기 (나중으로 미루기)

struct MyHomeMain: View {
    @EnvironmentObject var userManager: UserManager
    @State private var userName: String = ""
    @State private var schoolName: String = ""
    @State private var profileImageURL: URL? // 프로필 이미지 URL
    
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
                print("문서 데이터: \(data ?? [:])")
                
                if let userName = data?["name"] as? String,
                   let schoolIdx = data?["school_idx"] as? String {
                    self.userName = userName
                    fetchSchoolName(schoolIdx: schoolIdx)
                } else {
                    print("사용자 데이터를 찾을 수 없습니다. userName 또는 school_idx가 없습니다.")
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
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                        
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
                        
                        NavigationLink{InterestedPosts()}label:{
                            HStack(){
                                Image(systemName:"heart")
                                Text("관심 목록")
                                    .font(.title2)
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
                                    .font(.title2)
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
                                    .font(.title2)
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
                            .font(.title)
                            .bold()
                            .padding(.trailing, 200)
                        
                        NavigationLink(destination: PolicyView()) {
                            HStack {
                                Text("이용약관 (개인 정보 처리 방침)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(Color.black)
                                
                                Spacer()
                            }
                            .padding(.trailing, 50)
                        }
                        
                        NavigationLink(destination: FAQListView()){
                            HStack {
                                Text("자주하는 질문 FAQ")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(Color.black)
                                
                                Spacer()
                            }
                            .padding(.trailing, 50)
                        }
                        
                        NavigationLink(destination: AccountInfoView()) {
                            HStack {
                                Text("계정 정보")
                                    .font(.title2)
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

