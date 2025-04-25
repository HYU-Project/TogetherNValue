import SwiftUI

struct ChatInputView: View {
    @Binding var newMessage: String
    @Binding var isShowingPhotoOptions: Bool
    @Binding var isShowingPhotoPicker: Bool
    @Binding var isShowingCamera: Bool
    var sendMessageAction: () -> Void

    var body: some View {
        HStack {
            Button(action: { isShowingPhotoOptions = true }) {
                Image(systemName: "plus")
                    .font(.title)
                    .padding()
                    .foregroundColor(.blue)
            }
            .actionSheet(isPresented: $isShowingPhotoOptions) {
                ActionSheet(
                    title: Text("사진 추가"),
                    buttons: [
                        .default(Text("앨범에서 선택")) { isShowingPhotoPicker = true },
                        .default(Text("카메라 열기")) { isShowingCamera = true },
                        .cancel()
                    ]
                )
            }

            TextField("메시지를 입력하세요", text: $newMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minHeight: 40)

            Button(action: {
                sendMessageAction()
                newMessage = ""
            }) {
                Text("전송")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

