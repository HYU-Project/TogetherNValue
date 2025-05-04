import SwiftUI

struct PostInfoView: View {
    var postDetails: FetchPostInfo?
    var postImages: [PostImage]
    var postIdx: String
    @Binding var isShowingActionSheet: Bool
    var getActionSheetButtons: () -> [ActionSheet.Button]

    var body: some View {
        if let postDetails = postDetails {
            HStack {
                NavigationLink(destination: DetailPost(post_idx: postIdx)) {
                    if let firstImage = postImages.first,
                       let imageURL = URL(string: firstImage.image_url) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty: ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                Image("NoImage")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image("NoImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .clipped()
                    }

                    VStack(alignment: .leading) {
                        Text(postDetails.title)
                            .font(.headline)
                            .foregroundColor(.black)
                            .bold()
                        Text(postDetails.location)
                            .foregroundColor(.black)
                            .font(.subheadline)
                        Text(postDetails.post_status)
                            .font(.subheadline)
                            .foregroundColor(postDetails.post_status == "거래가능" ? .green : .red)
                    }
                }

                Spacer()

                Button(action: { isShowingActionSheet = true }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title)
                        .foregroundColor(.black)
                }
                .padding()
                .actionSheet(isPresented: $isShowingActionSheet) {
                    ActionSheet(title: Text("옵션 선택"), buttons: getActionSheetButtons())
                }
            }
            .padding()
        } else {
            Text("게시물 정보를 불러오는 중...")
                .padding()
        }
    }
}
