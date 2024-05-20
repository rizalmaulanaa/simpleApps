import SwiftUI
import PhotosUI

struct PhotosView: View {
    @State private var selectedImage: Image?
    @State private var selectedImageUI: UIImage?
    @State private var apiResponse: [resultData]?
    @State private var isShowingImagePickerPhoto = false
    @State private var isShowingImagePickerLib = false
    @State private var isLoading = false
    @State private var isDownload = false
    @State private var isErrorDownload = false
    @State private var imageData: Data?
    
    var body: some View {
        ZStack(alignment: .center){
            if self.isLoading {
                ProgressView("Uploading....")
            } else {
                VStack {
                    if let image = selectedImage, let res = apiResponse, let imageUI = selectedImageUI {
//                        BoundingBoxView(image: image, imageUI: imageUI, boundingBoxes: res[0].bbx!, boundingBoxesN: res[0].bbxN!, imageShape: res[0].imageShape!)
                        BoundingBoxViewDouble(image: image, imageUI: imageUI, boundingBoxes1: res[0].bbxN!, boundingBoxes2: res[1].bbxN!, imageShape: res[0].imageShape!)
//                        let _ = print(res)
                        
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
                ImagePicker(sourceType: .photoLibrary, sourceTypeTemp: .camera, image: self.$selectedImage, imageUI: self.$selectedImageUI, isShown: self.$isShowingImagePickerLib, isLoading: self.$isLoading, isDownload: self.$isDownload, funtionTap: {
                    sendImageToAPI(image: self.selectedImageUI!)
                })
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
                ImagePicker(sourceType: .camera, sourceTypeTemp: .camera, image: self.$selectedImage, imageUI:self.$selectedImageUI, isShown: self.$isShowingImagePickerPhoto, isLoading: self.$isLoading, isDownload: self.$isDownload, funtionTap: {
                    sendImageToAPI(image: self.selectedImageUI!)
                })
            }
        }.frame(minHeight: 10, maxHeight: 80)
        
        ZStack(alignment: .center) {
            if let imageUI = selectedImageUI, !self.isLoading {
                if self.isDownload {
                    if self.isErrorDownload {
                        Text("Error!")
                            .foregroundColor(.primary)
                            .padding(2)
                            .background(.red)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.red, lineWidth: 3)
                            )
                    } else {
                        Text("Done!")
                            .foregroundColor(.primary)
                            .padding(2)
                            .background(.blue)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.blue, lineWidth: 3)
                            )
                    }
                } else {
                    Button("Save Image") {
                        saveImageToLibrary(imageUI)
                    }
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(.gray)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.gray, lineWidth: 5)
                    )
                }
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
    
    func createBody(with imageData: Data, json: Data, boundary: String) -> Data {
        var body = Data()
        
        // Append image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Append JSON data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"json_data\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(json)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    func sendImageToAPI(image: UIImage){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var apiDecode = [resultData(), resultData()]
            let semaphore = DispatchSemaphore(value: 0)
            
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to data")
                return
            }
            
            // Construct URL for your Python backend
            guard let url = URL(string: "http://192.168.100.66:2804/recognition") else {
                print("Invalid URL")
                return
            }
            
            let additionalDataJSON = """
            [
                {
                    "model_conf": [{
                        "id": 1,
                        "model_name": "YOLO_m_60",
                        "status": false
                    },{
                        "id": 2,
                        "model_name": "YOLO_n_100-plate2",
                        "status": true
                    }]
                }
            ]
            """.data(using: .utf8)!
            
            do {
                let decoder = JSONDecoder()
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted  // For easier reading of the output JSON

                let additionalData = try decoder.decode([AdditionalData].self, from: additionalDataJSON)
                let jsonData = try encoder.encode(additionalData)
                
                // Construct the request
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                let boundary = "Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = createBody(with: imageData, json: jsonData, boundary: boundary)
                            
                // Send the request
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error sending data to Python backend: \(error)")
                    }
                    
                    // Handle response if needed
                    if let data = data {
                        let decode = handleAPIResponse(responseData: data)

                        apiDecode[0].name = decode[0].name
                        apiDecode[0].prediction = decode[0].prediction
                        apiDecode[0].conf = decode[0].conf
                        apiDecode[0].bbx = decode[0].bbx
                        apiDecode[0].bbxN = decode[0].bbxN
                        apiDecode[0].imageShape = decode[0].imageShape
                        
                        apiDecode[1].name = decode[1].name
                        apiDecode[1].prediction = decode[1].prediction
                        apiDecode[1].conf = decode[1].conf
                        apiDecode[1].bbx = decode[1].bbx
                        apiDecode[1].bbxN = decode[1].bbxN
                        apiDecode[1].imageShape = decode[1].imageShape
                        semaphore.signal()
                    }
                }.resume()
                
            } catch {
                print("Error encoding JSON data: \(error)")
            }
            
            semaphore.wait()
            self.apiResponse = apiDecode
            self.isLoading = false
        }
    }
    
    func handleAPIResponse(responseData: Data) -> [resultData] {
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode([resultData].self, from: responseData)
            
            // Access the parsed data from the API response
            return apiResponse
        } catch {
            print("Error decoding API response: \(error)")
            return [resultData()]
        }
    }
    
    func saveImageToLibrary(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            if success {
                self.isDownload = true
            } else {
                self.isErrorDownload = true
                print("Error saving image:", error?.localizedDescription ?? "Unknown error")
            }
        }
    }
}

#Preview {
    PhotosView()
}
