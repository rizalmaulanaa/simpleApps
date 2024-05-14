import SwiftUI

struct BoundingBox: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.red, lineWidth: 5)
            .frame(width: 300, height: 100)
            .position(x: UIScreen.main.bounds.midX , y: UIScreen.main.bounds.midY - 200)
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}
