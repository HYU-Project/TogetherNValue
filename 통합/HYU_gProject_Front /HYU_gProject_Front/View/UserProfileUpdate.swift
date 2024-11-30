
//  UserProfileUpdate : MyHomeMain에서 유저 프로필 수정

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

// Users에서 유저 이름, 프로필 이미지, 이메일을 가져와야함
// 프로필 이미지 url을 통해 storage에 저장된 실제 이미지 가져오기 (미완효)

struct UserProfileUpdate: View {
    @State private var userName: String = ""
    @State private var user_schoolEmail: String = ""
    
    @State private var user = Users(
        user_idx: 4,
        userName: "김무명",
        user_phoneNum: "010-3456-8901",
        school_idx: 2,
        user_schoolEmail: "dsdaasdfs1004@hanyang.ac.kr",
        profile_image_url: "u.r.l.to.pro/file/image3",
        created_at: "2024-09-15 13:01"
    )
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? // 선택된 이미지를 저장하는 상태 변수
    
    private var db = Firestore.firestore()
    
    private var storage = Storage.storage()
    
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
        
        db.collection("Users").document(userIdx).getDocument{
            document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let userName = data?["userName"] as? String,
                   let profile_image_url = data?["profile_image_url"] as? String,
                   let user_schoolEmail = data?["user_schoolEmail"] as? String {
                    self.userName = userName
                    self.user_schoolEmail = user_schoolEmail
                    
                    // storage에서 user의 프로필 이미지 PNG, JPG 가져오기
                }
            }
        }
        
        
    }
        
    var body: some View {
        VStack {
            HStack {
                Text("프로필 수정")
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            .padding(.bottom)
            
            // 프로필 이미지
            ZStack {
                if let selectedImage = selectedImage {
                    // 선택된 이미지가 있으면 해당 이미지를 표시
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        
                } else if let profileURL = user.profile_image_url, let url = URL(string: profileURL) {
                    // 유저가 등록한 기존 이미지
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 3))
                                .shadow(radius: 5)
                        case .failure:
                            // 기본 이미지 표시
                            defaultProfileImage
                        @unknown default:
                            defaultProfileImage
                        }
                    }
                } else {
                    defaultProfileImage
                }
            }
            .padding(.bottom)
            
            // 프로필 사진 변경 버튼
            Button(action: {
                // 이미지 선택기 표시
                showImagePicker = true
            }) {
                Text("프로필 사진 변경")
                    .foregroundColor(.black)
                    .font(.headline)
                    .bold()
                    .frame(width: 150, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.bottom)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 100)
                .overlay(
                    VStack {
                        Text(userName)
                        Text(user_schoolEmail) // 학교 이메일 표시
                    }
                    .foregroundColor(.gray)
                )
                .foregroundColor(.gray.opacity(0.1))
                .padding()
            
            Spacer()
            
            // 수정하기 버튼
            Button(action: {
                // 변경한 프로필 사진 저장하기 (url은 Users에 실제 이미지는 storage에)
                updateUserProfile()
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black, lineWidth: 4)
                    .frame(width: 350, height: 70)
                    .overlay(
                        Text("수정하기")
                            .foregroundColor(.black)
                            .font(.title2)
                            .bold()
                    )
            }
            
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
    }
    
    // 기본 프로필 이미지
    private var defaultProfileImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(.gray.opacity(0.5))
    }
    
    func updateUserProfile(){
        guard let userId = Auth.auth().currentUser?.uid else {
                    print("로그인된 사용자가 없습니다.")
                    return
                }
        
        // storage에 실제 이미지 저장하는 함수 호출 추가
        db.collection("Users").document(userId).updateData(["userName" : userName ]){ // "profile_image_url" 도 추가해야함
            error in
            if let error = error {
                print("Firestore 업데이트 실패: \(error.localizedDescription)")
            }
            else {
                print("프로필이 성공적으로 업데이트되었습니다.")
            }
        }
        
    }
    
    // storage 이미지 업로드 함수
}

struct UserProfileUpdate_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileUpdate()
    }
}
