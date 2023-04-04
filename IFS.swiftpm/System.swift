import Foundation

extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}

extension CGAffineTransform {
    init(iHat: CGPoint, jHat: CGPoint, shift: CGPoint) {
        self.init(iHat.x, iHat.y, jHat.x, jHat.y, shift.x, shift.y)
    }
}

class IFSSystem {
    var position: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var transformations: [CGAffineTransform] = []
    var transformWeight: [CGFloat] = []
    
    init() {}
    
    private func normalizeWeight() {
        let sum = transformWeight.sum()
        transformWeight = transformWeight.map({$0 / sum})
    }

    func addTransformation(_ t: CGAffineTransform, weight: CGFloat = 1.0) {
        transformations.append(t)
        normalizeWeight()
    }
    
    func chaosGameStep() -> CGPoint {
        let t = transformations.randomElement()!
        position = position.applying(t)
        return position
    }
}
