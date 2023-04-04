import SwiftUI

struct IFSCanvas: View {
    @State private var points: [CGPoint] = []
    private let calcQueue = DispatchQueue(label: "ifs_calc", qos: .background)
    public var chaosSamples = 10000
    public var ifs: IFSSystem
    
    private func renderImage() {
        var _pointsCalculating: [CGPoint] = []
        for _ in 0 ..< chaosSamples {
            _pointsCalculating.append(ifs.chaosGameStep())
        }
        points = _pointsCalculating
    }
    
    private func getNormTransform(_ size: CGSize) -> CGAffineTransform {
        let width = size.width
        let height = size.height
        let imageWH = min(width, height)
        
        let shift: CGPoint
        if width > height {
            // -----------------
            // |   |       |   |
            // |   | Squ-  |   |
            // |   | are   |   |
            // |   |       |   |
            // -----------------
            shift = CGPoint(x: (width - imageWH) / 2, y: 0)
        } else {
            shift = CGPoint(x: 0, y: (height - imageWH) / 2)
        }
        
        return CGAffineTransform(iHat: CGPoint(x: imageWH, y: 0), jHat: CGPoint(x: 0, y: imageWH), shift: shift)
    }
    
    var body: some View {
        VStack {
            Canvas { context, size in
                let tr = getNormTransform(size)
                for p in points {
                    let path = Path { path in
                        let radius: CGFloat = 1
                        path.addArc(center: p.applying(tr), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                    }
                    context.fill(path, with: .color(.blue))
                }
            }
            .onAppear() {
                calcQueue.async { renderImage() }
            }
        }
    }
}

