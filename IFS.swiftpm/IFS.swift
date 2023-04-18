import Foundation
import CoreGraphics

class IFSSystem: ObservableObject {
    var position: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @Published var transforms: [CGAffineTransform] = []
    private var colors: [CGColor] = []
    
    init() {}
    
    func addTransform(_ t: CGAffineTransform, weight: Double = 1.0) {
        transforms.append(t)
        colors.append(CGColor(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1),
            alpha: 0.9
        ))
    }
    
    func chaosGameStep() -> (CGPoint, CGColor) {
        let selected = Int.random(in: 0..<transforms.count)
        position = position.applying(transforms[selected])
        return (position, colors[selected])
    }
}
