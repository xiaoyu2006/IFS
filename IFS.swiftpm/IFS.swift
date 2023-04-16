import Foundation
import CoreGraphics

class IFSSystem: ObservableObject {
    var position: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @Published var transforms: [CGAffineTransform] = []
    private var transformWeight: [Double] = []
    private var totalTransformWeight: Double = 0
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
        transformWeight.append(weight)
        totalTransformWeight += weight
    }
    
    func chaosGameStep() -> (CGPoint, CGColor) {
        let choice = Double.random(in: 0...totalTransformWeight)
        var current: Double = 0
        var currentIndex = 0
        while (current <= choice) {
            current += transformWeight[currentIndex]
            currentIndex += 1
        }
        let selected = currentIndex - 1
        position = position.applying(transforms[selected])
        return (position, colors[selected])
    }
}
