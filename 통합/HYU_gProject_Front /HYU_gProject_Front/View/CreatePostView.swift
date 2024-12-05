
//  CreatePostView : 게시글 작성 폼

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// Posts에 Document Id,user_idx, post_category, post_categoryType, title, post_content,location, want_num, created_at 삽입
// TODO: PostImage에 Document Id, post의 document id, postImageURL 삽입
// TODO: postImageURL에는 URL만 저장, 실제 이미지는 storage에 저장

struct CreatePost: Codable{
    var user_idx: String
    var post_category: String
    var post_categoryType: String
    var title: String
    var post_content: String
    var location: String
    var want_num: Int
    var created_at: Timestamp
}

struct CreatePostView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @Environment(\.dismiss) var dismiss // 창 닫기
    @State private var isValidPost = false // 게시물 폼 유효성
    
    @State private var createPost = Post(post_idx: 0, user_idx: 0, post_category: "", post_categoryType: "", title: "", post_content: "", location: "", want_num: 2, post_status: "active", created_at: "", postImages: [], post_likeCnt: 0, post_commentCnt: 0)
    
    let categories = ["공구", "나눔"]
    let categoryTypes = ["물품", "식재료", "배달"]
    let peopleOptions = Array(2...5)
    
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
   
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack {
                    HStack{
                        Button(action: {
                            dismiss()
                        }){
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20)
                                .foregroundColor(Color.black)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    
                    HStack{
                        Text("* 사진 첨부")
                            .font(.title2)
                            .bold()
                            .padding(.trailing, 250)
                    }
                        
                        Button(action: {
                            showImagePicker = true
                        }){
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
                    
                    VStack(alignment: .leading) {
                        Text("* 글 제목")
                            .font(.title2)
                            .bold()
                        
                        TextField("제품명을 반드시 포함해서 작성해주세요.", text: $createPost.title)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                        
                    }
                    .padding()
                    
                    HStack {
                        Text("* 거래 방식 & 카테고리")
                            .font(.title2)
                            .bold()
                            .padding(.trailing, 140)
                    }
                    
                    VStack{
                        HStack{
                            ForEach(categories , id: \.self){
                                category in
                                Button(action: {
                                    createPost.post_category = category
                                }){
                                    Text(category)
                                        .padding()
                                        .background(createPost.post_category == category ? Color.blue : Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        
                        HStack{
                            ForEach(categoryTypes, id: \.self){
                                categoryType in
                                Button(action: {
                                    createPost.post_categoryType = categoryType
                                }){
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
                    
                    VStack(alignment: .leading){
                        Text("* 거래 장소")
                            .font(.title2)
                            .bold()
                        
                        TextField("학교 내 장소로 작성해주세요.", text: $createPost.location)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                        
                    }
                    .padding()
                    
                    VStack(alignment: .leading){
                        HStack {
                            Text("   * 희망 인원수")
                                .font(.title2)
                                .bold()
                            Text("(본인 포함해서 선택)")
                        }
                        HStack{
                            Picker("", selection: $createPost.want_num){
                                ForEach(peopleOptions, id: \.self){
                                    number in
                                    Text("\(number)명")
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    
                    VStack(alignment: .leading){
                        Text("* 글 내용")
                            .font(.title2)
                            .bold()
                        
                        TextEditor(text: $createPost.post_content)
                            .frame(height: 200)
                            .border(Color.gray, width: 1)
                            .padding()
                    }
                    .padding()
                    
                    Button(action: {
                        
                        dismiss()
                    }){
                        Text("작성 완료")
                            .font(.title2)
                            .foregroundColor(Color.black)
                            .bold()
                    }
                    .padding()
                    .frame(width: 350)
                    .background(isValidPost ? Color.blue : Color.accentColor)
                    .cornerRadius(10)
                    .onAppear{
                        validatePost() // 유효성 검사 함수
                    }
                    .disabled(!isValidPost)
                    
                }
                .padding()
            }
        }
    }
    
    func validatePost(){
        isValidPost = !createPost.title.isEmpty && !createPost.post_category.isEmpty && !createPost.post_categoryType.isEmpty && !createPost.location.isEmpty && (createPost.want_num >= 2 && createPost.want_num <= 5) && !createPost.post_content.isEmpty
        }
    
    private func saveImages() {
        var postImages: [PostImage] = []
        
        for selectedImage in selectedImages {
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                do {
                    try imageData.write(to: fileURL)
                    let postImage = PostImage(image_idx: Int.random(in: 1...1000), post_idx: createPost.post_idx, image_url: fileURL.path) // 이미지를 PostImage로 저장
                    postImages.append(postImage)
                } catch {
                    print("이미지 저장 오류: \(error)")
                }
            }
        }
        
        createPost.postImages = postImages // 저장된 이미지들을 Post에 연결
    }
        
    
    private func savePostToDatabase(){
        // 데이터베이스 저장 함수 구현
    }
}


#Preview {
    CreatePostView()
}

