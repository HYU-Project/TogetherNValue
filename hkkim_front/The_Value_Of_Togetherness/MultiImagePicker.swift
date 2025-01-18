
//  MultiImagePicker.swift : 게시글 생성하기에서 다중 이미지 업로드 하기 위해

import SwiftUI
import PhotosUI

struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0  // 무제한 선택 가능, 원하는 만큼 이미지 선택
        config.filter = .images  // 이미지 필터링
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker

        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    guard let uiImage = object as? UIImage else { return }
                    DispatchQueue.main.async {
                        self.parent.selectedImages.append(uiImage)
                    }
                }
            }
            picker.dismiss(animated: true)
        }

        func pickerDidCancel(_ picker: PHPickerViewController) {
            picker.dismiss(animated: true)
        }
    }
}
