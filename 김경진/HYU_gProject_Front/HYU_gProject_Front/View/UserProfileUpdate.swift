
//  UserProfileUpdate : MyHomeMain에서 유저 프로필 수정

import SwiftUI

struct UserProfileUpdate: View {
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
                        Text(user.userName)
                        Text(user.user_schoolEmail) // 학교 이메일 표시
                    }
                    .foregroundColor(.gray)
                )
                .foregroundColor(.gray.opacity(0.1))
                .padding()
            
            Spacer()
            
            // 수정하기 버튼
            Button(action: {
                // 변경한 프로필 사진 저장하기
                // 실제 저장 동작을 추가해야 함
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
}

struct UserProfileUpdate_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileUpdate()
    }
}
