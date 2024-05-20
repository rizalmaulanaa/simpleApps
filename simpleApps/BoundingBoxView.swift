import SwiftUI

struct BoundingBoxView: View {
    let image: Image
    let imageUI: UIImage
    let boundingBoxes: [[Float]] // Array of arrays of Int representing bounding boxes
    let boundingBoxesN: [[Float]] // Array of arrays of Int representing bounding boxes
    let imageShape: [Int]
    
    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    @State private var imageSize: CGSize = .zero
    @State var additionY: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment: .center) {
                Image(uiImage: resizeImage(image: imageUI, geoHeight: geometry.size.height))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                
                ForEach(Array(self.boundingBoxes.enumerated()), id: \.offset) { index, boundingBox in
                    let fixX = self.width * CGFloat(boundingBox[0])
                    let fixY = (self.height * CGFloat(boundingBox[1])) + self.additionY
                    let fixW = self.width * CGFloat(boundingBox[2])
                    let fixH = self.height * CGFloat(boundingBox[3])
                    
                    Rectangle()
                        .stroke(Color.green, lineWidth: 2)
                        .opacity(0.8)
                        .frame(width: fixW,
                               height: fixH)
                        .position(x: fixX,
                                  y: fixY)
                }
            }
        }
    }
    
    func resizeImage(image: UIImage, geoHeight:CGFloat) -> UIImage {
        let width = image.size.width
        let height = image.size.height

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if width > height {
                // Landscape image
                // Use screen width if < than image width
//                self.width = width > UIScreen.main.bounds.width ? UIScreen.main.bounds.width : width
                self.width = UIScreen.main.bounds.width
                // Scale height
                self.height = self.width/width * height
            } else {
                // Portrait
                // Use 600 if image height > 600
                self.height = height > 400 ? 400 : height
                // Scale width
                self.width = self.height/height * width
            }
            
            if geoHeight > self.height{
                self.additionY = geoHeight - self.height
            }
        }
        return image
    }
}
