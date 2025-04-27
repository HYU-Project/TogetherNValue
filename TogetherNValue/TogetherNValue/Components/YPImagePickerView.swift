import YPImagePicker
import SwiftUI

struct YPImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .photo]
        config.showsPhotoFilters = false
        config.library.mediaType = .photo
        config.startOnScreen = .library
        config.hidesStatusBar = false
        config.hidesBottomBar = false

        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { items, _ in
            if let photo = items.singlePhoto {
                self.selectedImage = photo.image
            }
            self.presentationMode.wrappedValue.dismiss()
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: YPImagePicker, context: Context) {}

    class Coordinator: NSObject {
        let parent: YPImagePickerView

        init(parent: YPImagePickerView) {
            self.parent = parent
        }
    }
}

