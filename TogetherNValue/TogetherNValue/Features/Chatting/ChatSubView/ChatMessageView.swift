import SwiftUI

struct ChatMessageView: View {
    var message: Message
    var formatTimestamp: (Date) -> String

    var body: some View {
        VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.senderID == "system" {
                    Spacer()
                    Text(message.text)
                        .padding()
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(10)
                    Spacer()
                }
                else if let imageUrl = message.imageUrl, let url = URL(string: imageUrl) {
                    if message.isCurrentUser{
                        Spacer()
                        
                        AsyncImageView(url: url, isUploading: message.isUploading)
                    }
                    else {
                        AsyncImageView(url: url, isUploading: message.isUploading)
                                
                        Spacer()
                    }
                }
                else {
                    if message.isCurrentUser {
                        Spacer()
                        Text(message.text)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    } else {
                        Text(message.text)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }

            if message.senderID != "system" {
                Text(formatTimestamp(message.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

@ViewBuilder
func AsyncImageView(url: URL?, isUploading: Bool = false) -> some View {
    if isUploading {
        // 업로드 중 프리뷰
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 120, height: 100)
            .overlay(
                ProgressView()
            )
            .cornerRadius(10)
    } else if let url = url {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 100)
                    .clipped()
                    .cornerRadius(10)
            case .failure:
                Image("NoImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 100)
                    .clipped()
                    .cornerRadius(8)
            @unknown default:
                EmptyView()
            }
        }
    }
}

