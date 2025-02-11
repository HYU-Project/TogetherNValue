
import SwiftUI

struct RoomStateFilterView: View {
    @Binding var selectedRoomState: String
    var loadPosts: () -> Void
    
    var body: some View {
        HStack(spacing: 30) {
            ForEach(["참여중", "참여완료"], id: \.self) { state in
                Button(action: {
                    selectedRoomState = selectedRoomState == state ? "" : state
                    loadPosts()
                }) {
                    Text(state)
                        .frame(width: 100, height: 50)
                        .foregroundColor(selectedRoomState == state ? .white : .black)
                        .background(selectedRoomState == state ? Color.black : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
            }
        }
        .padding(.trailing, 10)
    }
}
