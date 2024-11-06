import SwiftUI

struct CommunityMain: View {
    var schoolName: String = "한양대학교 서울캠" // 임시로 학교 이름 설정
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    // 게시물 모델 (나중에 따로 뺄 것)
    struct Post: Identifiable {
        var id = UUID()
        var imageName: String
        var title: String
        var location: String
        // 게시물 업데이트 시간을 받아와서 현재 시간과의 차이 구해야함
    }

    // 더미 게시물 데이터
    var posts = [
        Post(imageName: "photo1", title: "Title 1", location: "location for post 1"),
        Post(imageName: "photo2", title: "Title 2", location: "location for post 2"),
        Post(imageName: "photo3", title: "Title 3", location: "location for post 3")
    ]
    
    
    var body: some View {
        VStack {
            Text(schoolName)
                .font(.title3)
                .fontWeight(.bold)
            
            // 광고 배너
            Text("여기에 광고 배너 들어가기")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal)
            
            HStack {
                
                Button("식재료") {
                selectedCategory = "식재료"
                }
                .frame(width:80.0, height: 50.0)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                                )
                .padding()
                
                Button("물품") {
                selectedCategory = "물품"
                }
                .frame(width:80.0, height: 50.0)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                                )
                .padding()
                
                Button("배달") {
                    selectedCategory = "배달"
                }
                .frame(width:80, height: 50)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                                )
                .padding()
            }
            .padding(.horizontal, 50.0)
            
            HStack {
                TextField("Search", text: $searchText)
                    .background(Color.clear)
                    .padding(.horizontal, 25.0)
                
                Button(action: {
                    
                }){
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.black)
                        .padding()
                }
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(posts) { post in
                        HStack() {
                            Image(post.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 50)
                                .clipped()
                                .cornerRadius(8)

                            VStack(alignment: .leading) {
                                Text("[\(post.title)]")
                                    .font(.headline)
                                    .padding(.top, 5)
                              .padding()
                                
                                Text(post.location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
            .background(Color.white)
    
    
        }
        .padding()
        
    }
}

#Preview {
    CommunityMain()
}
