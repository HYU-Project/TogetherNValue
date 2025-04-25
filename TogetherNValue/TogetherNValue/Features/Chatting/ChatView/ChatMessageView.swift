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
                        
                        AsyncImageView(url: url)
                    }
                    else {
                        AsyncImageView(url: url)
                                
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
func AsyncImageView(url: URL) -> some View {
    AsyncImage(url: url) { phase in
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image.resizable()
                .scaledToFit()
                .frame(width: 120, height: 100)
                .cornerRadius(10)
        case .failure:
            Image("NoImage")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 100)
                .cornerRadius(8)
                .foregroundColor(.gray)
        @unknown default:
            EmptyView()
        }
    }
}
