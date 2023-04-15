import SwiftUI

struct IFSImageView: View {
    @ObservedObject public var ifs: IFSSystem
    @State var size = CGSize.zero
    public var chaosSamples = 30000
    public var diameter: CGFloat = 10.0
    let upscaling: CGFloat = 8
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        ChildSizeReader(size: $size) {
            ZoomableScrollView {
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable().scaledToFit()
                } else {
                    Text("Rendering...")
                        .frame(width: size.width, height: size.height)
                }
            }
            .border(.black)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
            .onAppear {
                renderImageAsync(size: size)
            }
        }
    }
    
    private func renderImageAsync(size: CGSize) {
        uiImage = nil
        DispatchQueue.global(qos: .background).async {
            let renderSize = CGSize(width: size.width * upscaling, height: size.height * upscaling)
            
            func drawDot(in context: CGContext, at point: CGPoint, withColor color: CGColor, diameter: CGFloat) {
                let rect = CGRect(x: point.x - diameter/2, y: point.y - diameter/2, width: diameter, height: diameter)
                context.setFillColor(color)
                context.fillEllipse(in: rect)
            }
            
            let renderer = UIGraphicsImageRenderer(size: renderSize)
            let normalizeTr = getUnitRecToUpsideDown(size: renderSize)
            
            let image = renderer.image { ctx in
                for _ in 0 ..< chaosSamples {
                    let p = ifs.chaosGameStep().applying(normalizeTr)
                    let color = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
                    drawDot(in: ctx.cgContext, at: p, withColor: color, diameter: 6)
                }
            }
            
            DispatchQueue.main.async {
                uiImage = image
            }
        }
    }
}
