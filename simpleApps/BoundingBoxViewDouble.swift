import SwiftUI

struct BoundingBoxViewDouble: View {
    let image: Image
    let boundingBoxesN1: [[Float]] // Array of arrays of Int representing bounding boxes
    let boundingBoxesN2: [[Float]] // Array of arrays of Int representing bounding boxes
    let imageShape: [Int]
    @State private var imageSize: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment: .center) {
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                ForEach(Array(self.boundingBoxesN1.enumerated()), id: \.offset) { index, boundingBox in
                    let fixX = geometry.size.width * CGFloat(boundingBox[0])
                    let fixY = geometry.size.height * CGFloat(boundingBox[1])
                    let fixW = geometry.size.width * CGFloat(boundingBox[2])
                    let fixH = geometry.size.height * CGFloat(boundingBox[3])
                    
                    Rectangle()
                        .stroke(Color.green, lineWidth: 2)
                        .opacity(0.8)
                        .frame(width: fixW,
                               height: fixH)
                        .position(x: fixX,
                                  y: fixY)
                }
                
                ForEach(Array(self.boundingBoxesN2.enumerated()), id: \.offset) { index, boundingBox in
                    let fixX = geometry.size.width * CGFloat(boundingBox[0])
                    let fixY = geometry.size.height * CGFloat(boundingBox[1])
                    let fixW = geometry.size.width * CGFloat(boundingBox[2])
                    let fixH = geometry.size.height * CGFloat(boundingBox[3])
                    
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 2)
                        .opacity(0.8)
                        .frame(width: fixW,
                               height: fixH)
                        .position(x: fixX,
                                  y: fixY)
                }
            }
        }
    }
}
