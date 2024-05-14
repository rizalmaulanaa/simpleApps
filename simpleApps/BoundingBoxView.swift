import SwiftUI

struct BoundingBoxView: View {
    let image: Image
    let boundingBoxes: [[Float]] // Array of arrays of Int representing bounding boxes
    let boundingBoxesN: [[Float]] // Array of arrays of Int representing bounding boxes
    let imageShape: [Int]
    @State private var imageSize: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment: .center) {
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity) 
                
//                let ratioX = (CGFloat(imageShape[1]) / geometry.size.width)
//                let ratioY = (CGFloat(imageShape[0]) / geometry.size.height)
//                let ratioW = (geometry.size.width / CGFloat(imageShape[1]))
//                
                ForEach(Array(self.boundingBoxesN.enumerated()), id: \.offset) { index, boundingBox in
                    let fixX = geometry.size.width * CGFloat(boundingBox[0])
                    let fixY = geometry.size.height * CGFloat(boundingBox[1])
                    let fixW = geometry.size.width * CGFloat(boundingBox[2])
                    let fixH = geometry.size.height * CGFloat(boundingBox[3])
                    
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: fixW,
                               height: fixH)
                        .position(x: fixX,
                                  y: fixY)
                    
//                        .frame(width: CGFloat(boundingBox[2]) / ratioW,
//                               height: CGFloat(boundingBox[3]))
//                        .position(x: CGFloat(boundingBox[0]) / ratioX,
//                                  y: CGFloat(boundingBox[1]) / ratioY)
                }
            }
        }
    }
}
