import Foundation

class IFSSystem: ObservableObject {
    var position: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @Published var transforms: [CGAffineTransform] = []
    private var transformWeight: [Double] = []
    private var totalTransformWeight: Double = 0
    
    init() {}
    
    func addTransform(_ t: CGAffineTransform, weight: Double = 1.0) {
        transforms.append(t)
        transformWeight.append(weight)
        totalTransformWeight += weight
    }
    
    func chaosGameStep() -> CGPoint {
        let choice = Double.random(in: 0...totalTransformWeight)
        var current: Double = 0
        var currentIndex = 0
        while (current <= choice) {
            current += transformWeight[currentIndex]
            currentIndex += 1
        }
        position = position.applying(transforms[currentIndex - 1])
        return position
    }
}
