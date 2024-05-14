import SwiftUI

struct PhotosView: View {
    @State private var selectedImage: Image?
    @State private var selectedImageUI: UIImage?
    @State private var apiResponse: [resultData]?
    @State private var isShowingImagePickerPhoto = false
    @State private var isShowingImagePickerLib = false
    @State private var imageData: Data?
    
    var body: some View {
        VStack {
            if let image = selectedImage, let res = apiResponse {
//                BoundingBoxView(image: image, boundingBoxes: res.bbx!, boundingBoxesN: res.bbxN!, imageShape: res.imageShape!)
                BoundingBoxViewDouble(image: image, boundingBoxesN1: res[0].bbxN!, boundingBoxesN2: res[1].bbxN!, imageShape: res[0].imageShape!)
                
//                Text("Image Shape: \(res[0].imageShape!)")
//                    .foregroundColor(Color.blue)
                
                let twoDList1: [[Any]] = [
                    res[0].prediction ?? [""],
                    res[0].conf ?? [0.0677]
                ]
                
                List {
                    ForEach(twoDList1.indices, id: \.self) { rowIndex in
                        if rowIndex == 0{
                            Text("Prediction:")
                                .foregroundColor(Color.green)
                        }else{
                            Text("Probability:")
                                .foregroundColor(Color.green)
                        }
                        HStack {
                            ForEach(twoDList1[rowIndex].indices, id: \.self) { columnIndex in
                                self.getViewForElement(twoDList1[rowIndex][columnIndex])
                                    .font(.system(size: 14))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                }
                
                let twoDList2: [[Any]] = [
                    res[1].prediction ?? [""],
                    res[1].conf ?? [0.0677]
                ]
                
                List {
                    ForEach(twoDList2.indices, id: \.self) { rowIndex in
                        if rowIndex == 0{
                            Text("Prediction:")
                                .foregroundColor(Color.blue)
                        }else{
                            Text("Probability:")
                                .foregroundColor(Color.blue)
                        }
                        HStack {
                            ForEach(twoDList2[rowIndex].indices, id: \.self) { columnIndex in
                                self.getViewForElement(twoDList2[rowIndex][columnIndex])
                                    .font(.system(size: 14))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                }
            }
            
        }.frame(minHeight: 0, maxHeight: 600)
        
        HStack (alignment: .bottom) {
            VStack () {
                Button("Select Image") {
                    self.isShowingImagePickerLib = true
                }
                .foregroundColor(.primary)
                .padding(8)
                .background(.green)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.green, lineWidth: 5)
                )
            }
            .sheet(isPresented: $isShowingImagePickerLib) {
//                ImagePicker(sourceType: .photoLibrary, sourceTypeTemp: .camera, image: self.$selectedImage, imageUI:self.$selectedImageUI, res: self.$apiResponse, isShown: self.$isShowingImagePickerLib)
                
                ImagePickerDouble(sourceType: .photoLibrary, sourceTypeTemp: .camera, image: self.$selectedImage, imageUI:self.$selectedImageUI, res: self.$apiResponse, isShown: self.$isShowingImagePickerLib)
            }
            VStack () {
                Button("Take a Photo") {
                    self.isShowingImagePickerPhoto = true
                }
                .foregroundColor(.primary)
                .padding(8)
                .background(.brown)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.brown, lineWidth: 5)
                )
            }
            .sheet(isPresented: $isShowingImagePickerPhoto) {
//                ImagePicker(sourceType: .camera, sourceTypeTemp: .camera, image: self.$selectedImage, imageUI:self.$selectedImageUI, res: self.$apiResponse, isShown: self.$isShowingImagePickerPhoto)
                ImagePickerDouble(sourceType: .camera, sourceTypeTemp: .camera, image: self.$selectedImage, imageUI:self.$selectedImageUI, res: self.$apiResponse, isShown: self.$isShowingImagePickerPhoto)
            }
        }
    }
    func getViewForElement(_ element: Any) -> AnyView {
        let centeredText = { (text: String) -> AnyView in
            return AnyView(
                VStack {
                    Spacer()
                    Text(text)
                    Spacer()
                }
            )
        }
        
        if let text = element as? String {
            return centeredText(text)
        } else if let number = element as? Int {
            return centeredText("\(number)")
        } else if let float = element as? Float {
            let roundedFloat = String(format: "%.4f", float)
            return centeredText("\(roundedFloat)")
        } else if let bool = element as? Bool {
            return centeredText("\(bool)")
        } else {
            return AnyView(centeredText("Unknown Type"))
        }
    }
    
//    func createBody(with parameters: [String: Data], boundary: String) -> Data {
//        var body = Data()
//
//        for (key, value) in parameters {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            body.append(value)
//            body.append("\r\n".data(using: .utf8)!)
//        }
//
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        return body
//    }
//    
//    func sendImageToAPI(imageUI: UIImage) -> resultData {
////        uploadManager.isUploading = true
//        guard let imageData = imageUI.jpegData(compressionQuality: 0.8) else {
//            print("Invalid Convert Data")
//            return resultData()
//        }
//        
//        var apiDecode = resultData()
//        let semaphore = DispatchSemaphore(value: 0)
//        
//        // Construct URL for your Python backend
//        guard let url = URL(string: "http://192.168.100.76:2804/recognition") else {
//            print("Invalid URL")
//            return resultData()
//        }
//        
//        // Construct the request
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.httpBody = createBody(with: ["image": imageData], boundary: boundary)
//        
//        // Send the request
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error sending data to Python backend: \(error)")
//            }
//
//            // Handle response if needed
//            if let data = data {
//                let decode = self.handleAPIRespone(responseData: data)
//                apiDecode.name = decode.name
//                apiDecode.prediction = decode.prediction
//                apiDecode.conf = decode.conf
//                apiDecode.bbx = decode.bbx
//                apiDecode.bbxN = decode.bbxN
//                apiDecode.imageShape = decode.imageShape
//                semaphore.signal()
//            }
//        }.resume()
//        
//        semaphore.wait()
//        
//        uploadManager.isUploading = false
//        print(uploadManager.isUploading)
//        return apiDecode
//    }
//    
//    func handleAPIRespone(responseData: Data) -> resultData {
//        do {
//            let decoder = JSONDecoder()
//            let apiResponse = try decoder.decode([resultData].self, from: responseData)
//            // Access the parsed data from the API response
//            return apiResponse[0]
//        } catch {
//            print("Error decoding API response: \(error)")
//            return resultData()
//        }
//    }
}

#Preview {
    PhotosView()
}
