import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case photoLibrary
        case camera
    }
    
    var sourceType: SourceType
    var sourceTypeTemp: UIImagePickerController.SourceType
    @Binding var image: Image?
    @Binding var imageUI: UIImage?
    @Binding var isShown: Bool
    @Binding var isLoading: Bool
    @Binding var isDownload: Bool
    var funtionTap : () -> () = {}
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        switch sourceType {
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        case .camera:
            picker.sourceType = .camera
            
            let boundingBoxView = BoundingBox().eraseToAnyView().background(Color.clear)
            let viewController = UIHostingController(rootView: boundingBoxView)
            viewController.view.isUserInteractionEnabled = false
            
            picker.cameraOverlayView = viewController.view
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                if let imageResize = resizeImage(image: uiImage){
                    if let croppedImage = cropImageToBoundingBox(image: imageResize) {
                        if parent.sourceType == .camera{
                            parent.image = Image(uiImage: croppedImage)
                            parent.imageUI = croppedImage
                        } else {
                            parent.image = Image(uiImage: imageResize)
                            parent.imageUI = imageResize
                            
                        }
                    }
                }
            }
            parent.funtionTap()
            parent.isShown = false
            parent.isLoading = true
            parent.isDownload = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShown = false
        }
        
        func resizeImage(image: UIImage) -> UIImage? {
            let maxWidth: CGFloat = 600
            let maxHeight: CGFloat = 600
            
            let aspectRatio: CGFloat = min(maxWidth / image.size.width, maxHeight / image.size.height)
            let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            defer { UIGraphicsEndImageContext() }
            image.draw(in: CGRect(origin: .zero, size: newSize))
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        
        func cropImageToBoundingBox(image: UIImage) -> UIImage? {
            // Calculate the size and position of the image
            let imageSize = image.size
            let imageRect = CGRect(origin: .zero, size: imageSize)
            
            let testX = (image.size.width / UIScreen.main.bounds.midX)
            let testY = (image.size.height / UIScreen.main.bounds.midY)

            // Calculate the position and size of the bounding box relative to the image
            let boundingBoxRect = CGRect(x: UIScreen.main.bounds.midX - 150, y: UIScreen.main.bounds.midY - 350, width: 150 * testX, height: 100 * testY)
            
            // Intersect the image with the bounding box to get the region of interest
            guard let croppedImageRef = image.cgImage?.cropping(to: boundingBoxRect.intersection(imageRect)) else {
                return nil
            }
            
            // Create a new UIImage from the cropped CGImage
            return UIImage(cgImage: croppedImageRef, scale: image.scale, orientation: image.imageOrientation)
        }
    }
}
