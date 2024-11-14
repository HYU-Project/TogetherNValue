//
//  CreatePostView.swift
//  CommunityUI
//
//  Created by somin on 11/14/24.
//

import SwiftUI
struct CreatePost: Identifiable {
    var id = UUID()
    var title : String
    var content : String
    var post_category: String
    var post_categoryType: String
    var imageName: String
    var location: String
    var want_num: Int
}
struct CreatePostView: View {
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @Environment(\.dismiss) var dismiss // 창 닫기
    @State private var createPost = CreatePost(title: "", content: "", post_category: "", post_categoryType: "", imageName: "", location: "", want_num: 2)
    @State private var isValidPost = false // 게시물 폼 유효성
    
    let categories = ["공구", "나눔"]
    let categoryTypes = ["물품", "식재료", "배달"]
    let peopleOptions = [2, 3, 4, 5]
    
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
                            if let selectedImage = selectedImage {
                                                        Image(uiImage: selectedImage)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 150)
                                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    } else {
                                                        Image(systemName: "photo.badge.plus.fill")
                                                    .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 100, height: 70)
                                                            .foregroundColor(.gray)
                                                    }
                        }
                        .sheet(isPresented: $showImagePicker) {
                                                ImagePicker(image: $selectedImage)
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
                        
                        TextEditor(text: $createPost.content)
                            .frame(height: 200)
                            .border(Color.gray, width: 1)
                            .padding()
                    }
                    .padding()
                    
                    Button(action: {
                        saveImage()// 이미지 저장 함수
                        savePostToDatabase()// createPost를 db에 저장하는 함수
                        dismiss()
                    }){
                        Text("작성완료")
                            .font(.title2)
                            .foregroundColor(Color.black)
                    }
                    .padding()
                    .background(isValidPost ? Color.blue : Color.gray)
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
        isValidPost = !createPost.title.isEmpty && !createPost.post_category.isEmpty && !createPost.post_categoryType.isEmpty && !createPost.location.isEmpty && (createPost.want_num >= 2 && createPost.want_num <= 5) && !createPost.content.isEmpty
    }
    
    private func saveImage() {
            guard let selectedImage = selectedImage else { return }
            
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                do {
                    try imageData.write(to: fileURL)
                    createPost.imageName = fileURL.path // 이미지 경로를 createPost의 imageName에 저장
                } catch {
                    print("이미지 저장 오류: \(error)")
                }
            }
        }
    
    private func savePostToDatabase(){
        
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    CreatePostView()
}

