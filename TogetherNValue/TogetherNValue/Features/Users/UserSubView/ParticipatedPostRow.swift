import SwiftUI

struct ParticipatedPostRow: View {
    let post: ParticiaptePost
    
    var body: some View {
        HStack(spacing: 10) {
            if let imageUrlString = post.postImage_url,
               !imageUrlString.isEmpty,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 70, height: 70)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                    case .failure:
                        Image("NoImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image("NoImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                
                Text("#\(post.post_category) #\(post.post_categoryType)")
                    .foregroundColor(.gray)
                
                Text(post.post_status)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .background(post.post_status == "거래가능" ? Color.green : Color.black)
                    .cornerRadius(5)
            }

            Spacer()
        }
        .padding()
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
