import SwiftUI

struct PageOne: View {
    @State private var points: [CGPoint] = []
    @State private var ifs: IFSSystem = IFSSystem()
    
    var body: some View {
        VStack {
            Canvas { context, size in
                for p in points {
                    let path = Path { path in
                        let radius: CGFloat = 3
                        // TODO: NORM
                        path.addArc(center: CGPoint(x: p.x * 500, y: p.y * 500), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                    }
                    context.fill(path, with: .color(.blue))
                }
            }
            .padding(20)
            
            Button("Clear") {
                points.removeAll()
            }
            
            Button("Start") {
                ifs = IFSSystem()
                ifs.addTransformation(
                    iHat: CGPoint(x: 0.5, y: 0),
                    jHat: CGPoint(x: 0, y: 0.5),
                    shift: CGPoint.zero)
                ifs.addTransformation(
                    iHat: CGPoint(x: 0.5, y: 0),
                    jHat: CGPoint(x: 0, y: 0.5),
                    shift: CGPoint(x: 0.5, y: 0))
                ifs.addTransformation(
                    iHat: CGPoint(x: 0.5, y: 0),
                    jHat: CGPoint(x: 0, y: 0.5),
                    shift: CGPoint(x: 0.25, y: 0.433))
                for _ in 0 ..< 300 {
                    points.append(ifs.chaosGameStep())
                }
            }
        }
    }
}
