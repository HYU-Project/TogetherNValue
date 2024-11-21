

// MyHomeMain : 마이페이지, 마이홈 메인 화면

import SwiftUI

struct MyHomeMain: View {
    @State private var userProfile = Users(user_idx: 1, userName: "김무명", user_phoneNum: "010-1234-5678", school_idx: 1, user_schoolEmail: "", profile_image_url: "https://example.com/profile-image.jpg", created_at:"")
    
    @State private var schoolInfo = Schools(school_idx: 1, schoolName: "한양대학교 서울캠", schoolEmail: "@hanyang.ac.kr")
    
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
                                
                                Spacer()
                            }
                            .padding(.trailing, 50)
                        }
                        
                        NavigationLink(destination: FAQListView()){
                            HStack {
                                Text("자주하는 질문 FAQ")
                                    .font(.title3)
                                    .bold()
                                
                                Spacer()
                            }
                            .padding(.trailing, 50)
                        }
                        
                        NavigationLink(destination: AccountInfoView()) {
                            HStack {
                                Text("계정 정보")
                                    .font(.title3)
                                    .bold()
                                
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
