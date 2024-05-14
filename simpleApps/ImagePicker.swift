import SwiftUI

struct BoundingBox: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.red, lineWidth: 5)
            .frame(width: 300, height: 100)
            .position(x: UIScreen.main.bounds.midX , y: UIScreen.main.bounds.midY - 200)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case photoLibrary
        case camera
    }
    
    var sourceType: SourceType
    var sourceTypeTemp: UIImagePickerController.SourceType
    @Binding var image: Image?
    @Binding var imageUI: UIImage?
    @Binding var res: resultData?
    @Binding var isShown: Bool
    
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
    
    func createBody(with parameters: [String: Data], boundary: String) -> Data {
        var body = Data()

        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(value)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    func sendImageToAPI(imageData: Data) -> resultData {
        var apiDecode = resultData()
        let semaphore = DispatchSemaphore(value: 0)
        
        // Construct URL for your Python backend
        guard let url = URL(string: "http://192.168.100.56:2804/recognition") else {
            print("Invalid URL")
            return resultData()
        }
        
        // Construct the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(with: ["image": imageData], boundary: boundary)
        
        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending data to Python backend: \(error)")
            }

            // Handle response if needed
            if let data = data {
                let decode = self.handleAPIResponse(responseData: data)
                apiDecode.name = decode.name
                apiDecode.prediction = decode.prediction
                apiDecode.conf = decode.conf
                apiDecode.bbx = decode.bbx
                apiDecode.bbxN = decode.bbxN
                apiDecode.imageShape = decode.imageShape
                semaphore.signal()
            }
        }.resume()
        
        semaphore.wait()
        
        return apiDecode
    }
    
    func handleAPIResponse(responseData: Data) -> resultData {
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode([resultData].self, from: responseData)
            // Access the parsed data from the API response
            return apiResponse[0]
        } catch {
            print("Error decoding API response: \(error)")
            return resultData()
        }
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                if let imageResize = resizeImage(image: uiImage){
                    if let croppedImage = cropImageToBoundingBox(image: imageResize) {
                        if let imageDataCrop = croppedImage.jpegData(compressionQuality: 0.8), let imageData = imageResize.jpegData(compressionQuality: 0.8) {
                            if parent.sourceType == .camera{
                                let a = parent.sendImageToAPI(imageData: imageDataCrop)
                                parent.res = a
                                parent.image = Image(uiImage: croppedImage)
                                parent.imageUI = croppedImage
                            } else {
                                let a = parent.sendImageToAPI(imageData: imageData)
                                parent.res = a
                                parent.image = Image(uiImage: imageResize)
                                parent.imageUI = imageResize
                            }
                        }
                    }
                }
            }
            parent.isShown = false
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

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}
