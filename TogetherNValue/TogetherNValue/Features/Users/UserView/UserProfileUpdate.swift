
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct UserProfileUpdate: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var userName: String = ""
    @State private var schoolEmail: String = ""
    @State private var schoolName: String = ""
    @State private var profileImageURL: URL? // 프로필 이미지 URL
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? // 선택된 이미지를 저장하는 상태 변수
    @State private var isImageUpdated = false // 이미지가 수정되었는지 여부
    @State private var showAlert = false // 알림 표시 여부
    @State private var alertMessage = "" // 알림 메시지
    
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    
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

                // 사용자 이름과 학교 이메일
                if let userName = data?["name"] as? String {
                    self.userName = userName
                } else {
                    print("userName 데이터가 존재하지 않습니다.")
                }

                if let schoolEmail = data?["schoolEmail"] as? String {
                    self.schoolEmail = schoolEmail
                } else {
                    print("schoolEmail 데이터가 존재하지 않습니다.")
                }

                // 학교 정보 가져오기
                if let schoolIdx = data?["school_idx"] as? String {
                    fetchSchoolName(schoolIdx: schoolIdx)
                } else {
                    print("school_idx 데이터가 존재하지 않습니다.")
                }

                // 프로필 이미지 URL 처리
                if let profileImageString = data?["profile_image_url"] as? String, let url = URL(string: profileImageString) {
                    self.profileImageURL = url
                } else {
                    print("profile_image_url이 존재하지 않거나 잘못된 형식입니다.")
                    self.profileImageURL = nil // 기본 이미지를 표시하도록 설정
                }
            } else {
                print("사용자 문서가 Firestore에 존재하지 않습니다.")
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
    
    func updateProfileImage() {
        guard let userIdx = userManager.userId, let newImage = selectedImage else { return }

        let dispatchGroup = DispatchGroup()

        // 기존 이미지 삭제
        if let profileImageURL = profileImageURL {
            dispatchGroup.enter()
            if let path = extractStoragePath(from: profileImageURL) {
                let storageRef = storage.reference().child(path)
                storageRef.delete { error in
                    if let error = error {
                        print("기존 이미지를 삭제하는 중 오류 발생: \(error.localizedDescription)")
                    } else {
                        print("기존 이미지가 성공적으로 삭제되었습니다.")
                    }
                    dispatchGroup.leave()
                }
            } else {
                print("프로필 이미지 경로를 추출할 수 없습니다.")
                dispatchGroup.leave()
            }
        }

        // 새로운 이미지를 Firebase Storage에 업로드
        let fileName = UUID().uuidString + ".png"
        let storagePath = "users/\(userIdx)/\(fileName)"
        let storageRef = storage.reference().child(storagePath)

        guard let imageData = newImage.jpegData(compressionQuality: 0.8) else { return }

        dispatchGroup.notify(queue: .main) {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    self.alertMessage = "이미지를 업로드하는 중 오류 발생: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }

                // 업로드된 이미지의 URL을 Firestore에 업데이트
                storageRef.downloadURL { url, error in
                    if let error = error {
                        self.alertMessage = "업로드된 이미지 URL을 가져오는 중 오류 발생: \(error.localizedDescription)"
                        self.showAlert = true
                    } else if let url = url {
                        self.db.collection("users").document(userIdx).updateData([
                            "profile_image_url": url.absoluteString
                        ]) { error in
                            if let error = error {
                                self.alertMessage = "Firestore에 프로필 이미지 URL 업데이트 중 오류 발생: \(error.localizedDescription)"
                            } else {
                                self.alertMessage = "프로필이 성공적으로 수정되었습니다."
                                self.isImageUpdated = true
                            }
                            self.showAlert = true
                        }
                    }
                }
            }
        }
    }

    // Firebase Storage URL에서 경로 추출
    private func extractStoragePath(from url: URL) -> String? {
        let fullPath = url.path
        if let range = fullPath.range(of: "/o/") {
            let startIndex = fullPath.index(range.upperBound, offsetBy: 0)
            let encodedPath = String(fullPath[startIndex...])
            return encodedPath.removingPercentEncoding
        }
        return nil
    }

    
    var body: some View {
        VStack {
            HStack {
                Text("프로필 수정")
                    .font(.title)
                    .bold()
                    .padding()
                
                Spacer()
            }
            .padding(.bottom)
            
            // 프로필 이미지
            ZStack {
                if let selectedImage = selectedImage {
                    // 새로 선택된 이미지 표시
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                } else if let profileImageURL = profileImageURL, !isImageUpdated {
                    // 기존 프로필 이미지 표시
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
                    // 기본 이미지
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .foregroundColor(Color.gray)
                        .clipShape(Circle())
                }

                // 프로필 사진 변경 버튼
                Button(action: {
                    showImagePicker = true
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.black.opacity(0.7))
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 40, y: 40)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { newImage in
                guard let newImage = newImage else { return }
                print("새로운 이미지가 선택되었습니다: \(newImage)")
                // 선택된 이미지를 즉시 프로필 이미지로 반영
                self.profileImageURL = nil // 기존 이미지 무효화
            }

                
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 100)
                    .overlay(
                        VStack {
                            Text(userName)
                            Text(schoolName)
                            Text(schoolEmail)
                        }
                            .foregroundColor(.gray)
                    )
                    .foregroundColor(.gray.opacity(0.1))
                    .padding()
                
                Spacer()
                
                // 수정하기 버튼
                Button(action: {
                    updateProfileImage()
                }) {
                    Text("수정하기")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.white)
                        .frame(width: 300, height: 40)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
        }
        .padding()
        .onAppear {
            fetchUserData()
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text("알림"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("확인"), action: {
                      if alertMessage == "프로필이 수정되었습니다." {
                          // 홈화면으로 이동
                          dismiss()
                      }
                  })
            )
        }
    }
}

#Preview {
    UserProfileUpdate()
        .environmentObject(UserManager())
}
