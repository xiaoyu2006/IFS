import SwiftUI

struct IFSImageView: View {
    @ObservedObject public var ifs: IFSSystem
    @State var size = CGSize.zero
    public var chaosSamples = 40000
    public var diameter: CGFloat = 10.0
    let upscaling: CGFloat = 4
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        HStack {
            Button("Save Image") {
                if let image = uiImage {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }
            Group {
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
                    var p = ifs.chaosGameStep()
                    p.0 = p.0.applying(normalizeTr)
                    drawDot(in: ctx.cgContext, at: p.0, withColor: p.1, diameter: 6)
                }
            }
            
            DispatchQueue.main.async {
                uiImage = image
            }
        }
    }
}
