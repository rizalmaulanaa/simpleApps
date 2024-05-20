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

struct ModelConf: Codable {
    let id: Int
    let modelName: String
    let status: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case modelName = "model_name"
        case status
    }
}

struct AdditionalData: Codable {
    let modelConf: [ModelConf]

    enum CodingKeys: String, CodingKey {
        case modelConf = "model_conf"
    }
}
