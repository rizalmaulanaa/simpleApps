import SwiftUI

struct resultData: Codable {
    var name: String? = ""
    var prediction: [String]? = [""]
    var conf: [Float]? = [0.0]
    var bbx: [[Float]]? = [[0.0,0.0,0.0,0.0]]
    var bbxN: [[Float]]? = [[0.0,0.0,0.0,0.0]]
    var imageShape: [Int]? = [1,2,3]
}

class UploadManager: ObservableObject {
    @Published var isUploading = false
}
