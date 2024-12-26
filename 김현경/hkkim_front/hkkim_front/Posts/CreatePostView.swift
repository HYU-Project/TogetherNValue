
//  CreatePostView : 게시글 작성 폼

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

// TODO: PostImage에 Document Id, post의 document id, postImageURL 삽입
// TODO: postImageURL에는 URL만 저장, 실제 이미지는 storage에 저장 (나중에)

struct CreatePost {
    var user_idx: String
    var post_category: String
    var post_categoryType: String
    var title: String
    var post_content: String
    var location: String
    var want_num: Int
    var post_status: String
    var created_at: Date
    var school_idx: String
    var postImages: [CreatePostImage]
    
    func toDictionary() -> [String: Any] {
        return [
            "user_idx": user_idx,
            "post_category": post_category,
            "post_categoryType": post_categoryType,
            "title": title,
            "post_content": post_content,
            "location": location,
            "want_num": want_num,
            "post_status" : post_status,
            "created_at": Timestamp(date: created_at), // Firestore에서 사용하는 Timestamp
            "school_idx": school_idx,
            "postImages": postImages.map { $0.toDictionary() } // CreatePostImage -> Dictionary 변환
        ]
    }
}

struct CreatePostImage {
    var post_idx: String
    var image_url: String
    
    func toDictionary() -> [String: Any] {
        return [
            "post_idx": post_idx,
            "image_url": image_url
        ]
    }
}

struct CreatePostView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @Environment(\.dismiss) var dismiss // 창 닫기
    @State private var isValidPost = false // 게시물 폼 유효성
    
    @State private var createPost = CreatePost(user_idx: "", post_category: "", post_categoryType: "", title: "", post_content: "", location: "", want_num: 2, post_status: "거래중", created_at: Date(), school_idx: "", postImages: [])
    
    let categories = ["공구", "나눔"]
    let categoryTypes = ["물품", "식재료", "배달"]
    let peopleOptions = Array(2...5)
    
    private var db = Firestore.firestore()
    
   
    // 유저 학교 정보(school_idx) 가져오기
    func fetchSchoolIdx(completion: @escaping (String?) -> Void) {
        guard let userId = userManager.userId else {
            print("로그인한 유저가 없습니다.")
            completion(nil)
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let schoolIdx = data?["school_idx"] as? String {
                    completion(schoolIdx)
                } else {
                    print("school_idx를 찾을 수 없습니다.")
                    completion(nil)
                }
            } else {
                print("users 문서를 찾을 수 없습니다: \(error?.localizedDescription ?? "알 수 없는 에러")")
                completion(nil)
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20)
                                .foregroundColor(Color.black)
                        }
                        Spacer()
                    }
                    .padding()

                    // 제목
                    VStack(alignment: .leading) {
                        Text("* 글 제목")
                            .font(.title2)
                            .bold()

                        TextField("제품명을 반드시 포함해서 작성해주세요.", text: $createPost.title)
                            .onChange(of: createPost.title) { _ in
                                validatePost()
                            }

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    .padding()

                    // 거래 방식 & 카테고리
                    VStack {
                        HStack {
                            Text("* 거래 방식 & 카테고리")
                                .font(.title2)
                                .bold()
                                .padding(.trailing, 140)
                        }

                        VStack {
                            HStack {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        createPost.post_category = category
                                        validatePost() // 카테고리 변경 시 유효성 검사
                                    }) {
                                        Text(category)
                                            .padding()
                                            .background(createPost.post_category == category ? Color.blue : Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                            .foregroundColor(.black)
                                    }
                                }
                            }

                            HStack {
                                ForEach(categoryTypes, id: \.self) { categoryType in
                                    Button(action: {
                                        createPost.post_categoryType = categoryType
                                        validatePost() // 카테고리 타입 변경 시 유효성 검사
                                    }) {
                                        Text("# \(categoryType)")
                                            .padding()
                                            .background(createPost.post_categoryType == categoryType ? Color.yellow : Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                        .padding()
                    }

                    // 거래 장소
                    VStack(alignment: .leading) {
                        Text("* 거래 장소")
                            .font(.title2)
                            .bold()

                        TextField("학교 내 장소로 작성해주세요.", text: $createPost.location)
                            .onChange(of: createPost.location) { _ in
                                validatePost() // 장소 변경 시 유효성 검사
                            }

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    .padding()

                    // 희망 인원수
                    VStack(alignment: .leading) {
                        HStack {
                            Text("   * 희망 인원수")
                                .font(.title2)
                                .bold()
                            Text("(본인 포함해서 선택)")
                        }

                        HStack {
                            Picker("", selection: $createPost.want_num) {
                                ForEach(peopleOptions, id: \.self) { number in
                                    Text("\(number)명")
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: createPost.want_num) { _ in
                                validatePost() // 희망 인원수 변경 시 유효성 검사
                            }
                        }
                    }

                    // 글 내용
                    VStack(alignment: .leading) {
                        Text("* 글 내용")
                            .font(.title2)
                            .bold()

                        TextEditor(text: $createPost.post_content)
                            .frame(height: 200)
                            .border(Color.gray, width: 1)
                            .padding()
                            .onChange(of: createPost.post_content) { _ in
                                validatePost() // 글 내용 변경 시 유효성 검사
                            }
                    }
                    .padding()

                    // 이미지 첨부
                    VStack {
                        HStack {
                            Text("* 사진 첨부")
                                .font(.title2)
                                .bold()
                                .padding(.trailing, 250)
                        }

                        Button(action: {
                            showImagePicker = true
                        }) {
                            if selectedImages.isEmpty {
                                Image(systemName: "photo.badge.plus.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 70)
                                    .foregroundColor(.gray)
                            } else {
                                // 선택된 이미지들 보여주기
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(selectedImages, id: \.self) { image in
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 70)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $showImagePicker) {
                            MultiImagePicker(selectedImages: $selectedImages, sourceType: .photoLibrary)
                        }
                    }
                    .padding()

                    // 작성 완료 버튼
                    Button(action: {
                        savePostToDatabase()
                        dismiss()
                    }) {
                        Text("작성 완료")
                            .font(.title2)
                            .foregroundColor(Color.black)
                            .bold()
                    }
                    .padding()
                    .frame(width: 350)
                    .background(isValidPost ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .onAppear {
                        validatePost() // 화면이 나타날 때 유효성 검사
                    }
                    .disabled(!isValidPost)
                }
                .padding()
            }
        }
    }
    
    
    func validatePost() {
        isValidPost = !createPost.title.isEmpty &&
                      !createPost.post_category.isEmpty &&
                      !createPost.post_categoryType.isEmpty &&
                      !createPost.location.isEmpty &&
                      createPost.want_num > 0 &&
                      !createPost.post_content.isEmpty
    }
        
    private func savePostToDatabase() {
        guard let currentUserId = userManager.userId else {
            print("유저가 로그인되지 않았습니다.")
            return
        }

        // fetchSchoolIdx로 school_idx 가져오기
        fetchSchoolIdx { schoolIdx in
            guard let schoolIdx = schoolIdx else {
                print("school_idx를 가져올 수 없습니다.")
                return
            }

            // 게시글 생성 데이터 구성
            self.createPost.created_at = Date()
            self.createPost.user_idx = currentUserId
            self.createPost.school_idx = schoolIdx
            
            // Firestore에 데이터 저장
            var postRef: DocumentReference? = nil
            let postData = self.createPost.toDictionary()
            postRef = self.db.collection("posts").addDocument(data: postData) { error in
                if let error = error {
                    print("Post 데이터를 Firestore에 저장하는 중 오류 발생: \(error)")
                    return
                }
                
                guard let documentId = postRef?.documentID else { return }
                
                // 이미지 업로드 처리
                if !self.selectedImages.isEmpty {
                    self.saveImages(postDocumentId: documentId) { success in
                        if success {
                            print("post와 이미지가 성공적으로 저장되었습니다.")
                            self.dismiss()
                        } else {
                            print("이미지 업로드 중 오류 발생.")
                        }
                    }
                } else {
                    self.dismiss()
                }
            }
        }
    }
    
    // selectedImages가 UIImage 목록으로, 로컬 파일로 저장한 후 Firestore에 URL을 저장하는 방식
    private func saveImages(postDocumentId: String, completion: @escaping (Bool) -> Void) {
        var postImages: [CreatePostImage] = []
        
        for selectedImage in selectedImages {
            let fileName = UUID().uuidString + ".jpg"
            
            // 이미지를 로컬에 저장하고 URL을 가져옴
            if let fileURL = saveImageToDocuments(image: selectedImage, fileName: fileName) {
                // 로컬 파일 URL을 Firestore에 저장할 데이터로 변환
                let postImage = CreatePostImage(
                    post_idx: postDocumentId,
                    image_url: fileURL.absoluteString // 로컬 파일 URL 문자열을 저장
                )
                postImages.append(postImage)
            } else {
                print("이미지를 로컬 파일로 저장하는 데 실패했습니다.")
            }
        }

        // 로컬 URL을 Firestore에 저장
        if !postImages.isEmpty {
            savePostImagesToFirestore(postDocumentId: postDocumentId, postImages: postImages) { success in
                if success {
                    completion(true) // 이미지 저장 성공
                } else {
                    completion(false) // 이미지 저장 실패
                }
            }
        } else {
            print("저장할 이미지가 없습니다.")
            completion(false) // 저장할 이미지가 없는 경우
        }
    }

    
    private func saveImageToDocuments(image: UIImage, fileName: String) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("이미지를 로컬 파일로 저장하는 데 실패했습니다: \(error)")
            return nil
        }
    }
    
    private func savePostImagesToFirestore(postDocumentId: String, postImages: [CreatePostImage], completion: @escaping (Bool) -> Void) {
        let postImageRef = db.collection("posts").document(postDocumentId).collection("postImages")
        
        // Firestore batch 생성
        let batch = db.batch()

        for postImage in postImages {
            let imageDoc = postImageRef.document() // 이미지마다 고유한 document ID 생성
            
            // CreatePostImage 구조체의 toDictionary 메서드를 호출하여 데이터를 변환
            let postImageData = postImage.toDictionary()
            
            // 배치 작업에 데이터 추가
            batch.setData(postImageData, forDocument: imageDoc)
        }

        // 배치 커밋
        batch.commit { error in
            if let error = error {
                print("postImages 저장 중 오류 발생: \(error)")
                completion(false) // 실패 시 false 반환
            } else {
                print("postImages가 Firestore에 성공적으로 저장되었습니다.")
                completion(true) // 성공 시 true 반환
            }
        }
    }

}


#Preview {
    CreatePostView()
        .environmentObject(UserManager())
}

