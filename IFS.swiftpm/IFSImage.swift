import SwiftUI

//struct IFSCanvas: View {
//    @State private var points: [CGPoint] = []
//    @ObservedObject public var ifs: IFSSystem
//    public var chaosSamples = 10000
//    private let calcQueue = DispatchQueue(label: "ifs_calc", qos: .background)
//
//    private func renderImage() {
//        var _pointsCalculating: [CGPoint] = []
//        for _ in 0 ..< chaosSamples {
//            _pointsCalculating.append(ifs.chaosGameStep())
//        }
//        points = _pointsCalculating
//    }
//
//    var body: some View {
//        Canvas { context, size in
//            let tr = getUnitRecTo(size: size)
//            for p in points {
//                let path = Path { path in
//                    let radius: CGFloat = 1
//                    path.addArc(center: p.applying(tr), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
//                }
//                context.fill(path, with: .color(.blue))
//            }
//        }
//        .onAppear {
//            calcQueue.async {
//                renderImage()
//            }
//        }
//        //        GeometryReader { geometry in
//        //            let tr = getUnitRecTo(size: geometry.size)
//        //            ForEach(points) { p in
//        //                Path { path in
//        //                    let radius: CGFloat = 1
//        //                    path.addArc(center: p.point.applying(tr), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
//        //                }
//        //                .fill(Color.blue)
//        //            }
//        //        }
//        //        .aspectRatio(contentMode: .fit)
//        //        .onAppear() {
//        //            calcQueue.async { renderImage() }
//        //        }
//    }
//}

struct IFSImageView: View {
    @ObservedObject public var ifs: IFSSystem
    public var chaosSamples = 20000
    public var diameter: CGFloat = 10.0
    let upscaling: CGFloat = 4
    
    @State private var image: CGImage?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let cgImage = image {
                    ZoomableScrollView {
                        Image(cgImage, scale: upscaling, label: Text("IFS Result"))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                } else {
                    Text("Loading...")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .border(.black)
            .onAppear {
                // TODO: LAG
                let image = createCustomImage(size: geometry.size)
                self.image = image
            }
        }
    }
    
    private func createCustomImage(size: CGSize) -> CGImage {
        let renderSize = CGSize(width: size.width * upscaling, height: size.height * upscaling)
        
        func drawDot(in context: CGContext, at point: CGPoint, withColor color: CGColor, diameter: CGFloat) {
            let rect = CGRect(x: point.x - diameter/2, y: point.y - diameter/2, width: diameter, height: diameter)
            context.setFillColor(color)
            context.fillEllipse(in: rect)
        }
        
        let context = CGContext(data: nil, width: Int(renderSize.width), height: Int(renderSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        let tr = getUnitRecTo(size: renderSize)
        for _ in 0 ..< chaosSamples {
            let point: CGPoint = ifs.chaosGameStep().applying(tr)
            drawDot(in: context, at: point, withColor: CGColor(red: 0, green: 0, blue: 1, alpha: 1), diameter: diameter)
        }
        return context.makeImage()!
    }
}
