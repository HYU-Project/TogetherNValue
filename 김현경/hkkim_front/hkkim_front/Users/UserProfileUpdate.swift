//
//  UserProfileUpdate.swift
//  hkkim_front
//
//  Created by 김소민 on 12/26/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

// TODO: users에서 유저 이름, 학교 이메일, 학교 이름, 프로필 이미지를 가져와야함
// TODO: 프로필 이미지 url을 통해 storage에 저장된 실제 이미지 가져오기 (미완료)
// TODO: db update에서 프로필 이미지 (url & storage) (미완료)

struct UserProfileUpdate: View {
    @EnvironmentObject var userManager: UserManager
    @State private var userName: String = ""
    @State private var schoolEmail: String = ""
    @State private var schoolName: String = ""
    @State private var profileImageURL: URL? // 프로필 이미지 URL
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? // 선택된 이미지를 저장하는 상태 변수
    
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
                   let schoolEmail = data?["schoolEmail"] as? String,
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
                // 프로필 이미지 보여주기(기존 저장된 이미지 있으면 보여주고 null이면 default 이미지 보여주기)
                
                // 프로필 사진 변경 버튼
                Button(action: {
                    showImagePicker = true // 이미지 선택기 표시
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
                            Text("김무명")
                            Text("한양대학교 서울캠")
                        }
                            .foregroundColor(.gray)
                    )
                    .foregroundColor(.gray.opacity(0.1))
                    .padding()
                
                Spacer()
                
                // 수정하기 버튼
                Button(action: {
                    // 변경한 프로필 사진 저장하기
                }) {
                    Text("수정하기")
                        .foregroundColor(.black)
                        .background(Color.gray)
                        .font(.title2)
                        .bold()
                    
                }
                
            }
            .padding()
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
        }
        .padding()
    }
}

#Preview {
    UserProfileUpdate()
        .environmentObject(UserManager())
}
