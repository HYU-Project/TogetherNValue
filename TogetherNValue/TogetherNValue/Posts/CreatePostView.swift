
//  CreatePostView : 게시글 작성 폼

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

// TODO: PostImage에 Document Id, post의 document id, postImageURL 삽입
// TODO: postImageURL에는 URL만 저장, 실제 이미지는 storage에 저장 (나중에)

struct CreatePost {
    var post_idx: String? // 게시물 ID (Firestore 문서 ID)
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
    var order: Int // 업로드 순서를 나타내는 필드
    
    func toDictionary() -> [String: Any] {
        return [
            "post_idx": post_idx,
            "image_url": image_url,
            "order": order
        ]
    }
}

struct CreatePostView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @Environment(\.dismiss) var dismiss // 창 닫기
    @State private var isValidPost = false // 게시물 폼 유효성
    
    @State private var createPost: CreatePost
    @Binding var postDetails: PostInfo?
    let isEditMode: Bool // 수정 모드인지 여부
    
    init(post: CreatePost? = nil, postDetails: Binding<PostInfo?>, isEditMode: Bool = false) {
            self._createPost = State(initialValue: post ?? CreatePost(user_idx: "", post_category: "", post_categoryType: "", title: "", post_content: "", location: "", want_num: 1, post_status: "거래가능", created_at: Date(), school_idx: "", postImages: []))
            self._postDetails = postDetails
            self.isEditMode = isEditMode
        }
    
    let categories = ["공구", "나눔"]
    let categoryTypes = ["물품", "식재료", "배달"]
    let peopleOptions = Array(1...5)
    
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
                            Text("   * 거래 희망 인원수")
                                .font(.title2)
                                .bold()
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
                            .border(Color.gray, width: 2)
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
                                .padding(.trailing, 230)
                        }

                        ScrollView(.horizontal) {
                            HStack {
                                // 기존 이미지 표시 (수정 모드일 때만)
                                if isEditMode {
                                    ForEach(createPost.postImages, id: \.order) { image in
                                        ZStack(alignment: .topTrailing) { // ZStack에 alignment 추가
                                            AsyncImage(url: URL(string: image.image_url)) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(width: 100, height: 70)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 100, height: 70)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                case .failure:
                                                    Image(systemName: "xmark")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 100, height: 70)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }

                                            // 삭제 버튼
                                            if isEditMode { // isEditMode가 true일 때만 표시
                                                Button(action: {
                                                    withAnimation {
                                                        // 기존 이미지 배열에서 제거
                                                        createPost.postImages.removeAll { $0.image_url == image.image_url }
                                                    }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                }
                                                .offset(x: -5, y: 5) // 위치 조정
                                            }
                                        }
                                    }
                                }

                                // 새로 선택한 이미지 표시
                                ForEach(selectedImages, id: \.self) { image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))

                                        // 삭제 버튼
                                        Button(action: {
                                            withAnimation {
                                                selectedImages.removeAll { $0 == image }
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        .offset(x: -10, y: 10)
                                    }
                                }

                                // 이미지 추가 버튼
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    VStack {
                                        Image(systemName: "plus.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                        Text("추가")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.leading, 20)
                            }
                        }
                        .sheet(isPresented: $showImagePicker) {
                            MultiImagePicker(selectedImages: $selectedImages, sourceType: .photoLibrary)
                        }
                    }
                    .padding()

                    // 작성 완료 버튼
                    Button(action: {
                        if isEditMode {
                            updatePostToDatabase{
                                dismiss()
                                postDetails?.images = createPost.postImages.map {
                                    PostImages(post_idx: $0.post_idx, image_url: $0.image_url, order: $0.order)
                                }
                            }
                        }
                        else{
                            savePostToDatabase()
                            dismiss()
                        }
                    }) {
                        Text(isEditMode ? "수정 완료" : "작성 완료")
                            .font(.title2)
                            .foregroundColor(Color.white)
                            .bold()
                    }
                    .padding()
                    .frame(width: 350, height: 70)
                    .background(isValidPost ? Color.black : Color.gray.opacity(0.5))
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

        fetchSchoolIdx { schoolIdx in
            guard let schoolIdx = schoolIdx else {
                print("school_idx를 가져올 수 없습니다.")
                return
            }

            self.createPost.created_at = Date()
            self.createPost.user_idx = currentUserId
            self.createPost.school_idx = schoolIdx

            var postRef: DocumentReference? = nil
            let postData = self.createPost.toDictionary()

            // Firestore에 게시물 데이터 저장
            postRef = self.db.collection("posts").addDocument(data: postData) { error in
                if let error = error {
                    print("게시물 저장 중 오류 발생: \(error)")
                    return
                }
                
                guard let documentId = postRef?.documentID else { return }

                // 선택된 이미지가 있으면 업로드
                if !self.selectedImages.isEmpty {
                    self.saveImages(postDocumentId: documentId) { success in
                        DispatchQueue.main.async {
                            if success {
                                print("게시물과 이미지가 성공적으로 저장되었습니다.")
                                self.dismiss() // 저장 완료 후 닫기
                            } else {
                                print("이미지 업로드 중 오류 발생.")
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.dismiss() // 이미지가 없는 경우 즉시 닫기
                    }
                }
            }
        }
    }
    
    // Firebase Storage에 이미지를 업로드하고 다운로드 URL을 Firestore에 저장
    private func saveImages(postDocumentId: String, completion: @escaping (Bool) -> Void) {
        var postImages: [CreatePostImage] = []
        let storage = Storage.storage()
        let dispatchGroup = DispatchGroup()
        
        for (index, selectedImage) in selectedImages.enumerated() { // 이미지 인덱스로 순서 지정
            dispatchGroup.enter()
            let fileName = UUID().uuidString + ".png"
            let storageRef = storage.reference().child("posts/\(postDocumentId)/\(fileName)")
            
            guard let imageData = selectedImage.pngData() else {
                print("이미지를 PNG 데이터로 변환하는 데 실패했습니다.")
                dispatchGroup.leave()
                continue
            }
            
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Firebase Storage에 업로드 중 오류 발생: \(error)")
                    dispatchGroup.leave()
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("이미지 다운로드 URL을 가져오는 중 오류 발생: \(error)")
                    } else if let url = url {
                        let postImage = CreatePostImage(post_idx: postDocumentId, image_url: url.absoluteString, order: index) // `order` 추가
                        postImages.append(postImage)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !postImages.isEmpty {
                self.savePostImagesToFirestore(postDocumentId: postDocumentId, postImages: postImages, completion: completion)
            } else {
                print("저장할 이미지가 없습니다.")
                completion(false)
            }
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
        let batch = db.batch()

        for postImage in postImages {
            let imageDoc = postImageRef.document()
            let postImageData = postImage.toDictionary() // `order` 필드 포함
            batch.setData(postImageData, forDocument: imageDoc)
        }

        batch.commit { error in
            if let error = error {
                print("postImages 저장 중 오류 발생: \(error)")
                completion(false)
            } else {
                print("postImages가 Firestore에 성공적으로 저장되었습니다.")
                completion(true)
            }
        }
    }
    
    private func updatePostToDatabase(completion: @escaping () -> Void) {
        guard let postIdx = createPost.post_idx else {
            print("게시물 ID가 없습니다.")
            return
        }

        let storage = Storage.storage()
        let dispatchGroup = DispatchGroup()
        let postImagesCollectionRef = db.collection("posts").document(postIdx).collection("postImages")

        // Firebase Storage에서 삭제된 이미지 제거
        let initialPostImages = postDetails?.images ?? []
        let deletedImages = initialPostImages.filter { initialImage in
            !createPost.postImages.contains(where: { $0.image_url == initialImage.image_url })
        }

        for deletedImage in deletedImages {
            dispatchGroup.enter()
            let storageRef = storage.reference(forURL: deletedImage.image_url)
            storageRef.delete { error in
                if let error = error {
                    print("기존 이미지를 삭제하는 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("Firebase Storage에서 삭제 성공: \(deletedImage.image_url)")
                    postImagesCollectionRef.whereField("image_url", isEqualTo: deletedImage.image_url).getDocuments { snapshot, error in
                        if let error = error {
                            print("Firestore에서 삭제 중 오류 발생: \(error.localizedDescription)")
                        } else {
                            snapshot?.documents.forEach { $0.reference.delete() }
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }

        // 기존 이미지 `order` 재정렬
        for (index, postImage) in createPost.postImages.enumerated() {
            createPost.postImages[index].order = index
        }

        // 새로 추가된 이미지 업로드 처리
        for (index, newImage) in selectedImages.enumerated() {
            dispatchGroup.enter()
            let fileName = UUID().uuidString + ".png"
            let storageRef = storage.reference().child("posts/\(postIdx)/\(fileName)")

            guard let imageData = newImage.pngData() else {
                print("이미지를 PNG 데이터로 변환하는 데 실패했습니다.")
                dispatchGroup.leave()
                continue
            }

            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("새 이미지를 업로드하는 중 오류 발생: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("새 이미지 다운로드 URL을 가져오는 중 오류 발생: \(error.localizedDescription)")
                    } else if let url = url {
                        let newPostImage = CreatePostImage(post_idx: postIdx, image_url: url.absoluteString, order: createPost.postImages.count)
                        self.createPost.postImages.append(newPostImage)
                        postImagesCollectionRef.addDocument(data: newPostImage.toDictionary())
                    }
                    dispatchGroup.leave()
                }
            }
        }

        // 모든 작업 완료 후 Firestore의 posts 문서 업데이트
        dispatchGroup.notify(queue: .main) {
            let postData = self.createPost.toDictionary()
            self.db.collection("posts").document(postIdx).updateData(postData) { error in
                if let error = error {
                    print("게시물 업데이트 중 오류 발생: \(error.localizedDescription)")
                    return
                }
                print("게시물이 성공적으로 업데이트되었습니다.")
                completion() // 데이터 새로고침 트리거
            }
        }
    }

}
