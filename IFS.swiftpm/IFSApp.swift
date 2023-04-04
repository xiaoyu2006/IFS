import SwiftUI

@main
struct IFSApp: App {
    init() {
        ifs = IFSSystem()
        ifs.addTransformation(
            CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
                              jHat: CGPoint(x: 0, y: 0.5),
                              shift: CGPoint.zero))
        ifs.addTransformation(
            CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
                              jHat: CGPoint(x: 0, y: 0.5),
                              shift: CGPoint(x: 0.5, y: 0)))
        ifs.addTransformation(
            CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
                              jHat: CGPoint(x: 0, y: 0.5),
                              shift: CGPoint(x: 0.25, y: 0.433)))
    }
    
    var ifs: IFSSystem
    
    var body: some Scene {
        WindowGroup {
            IFSCanvas(chaosSamples: 20000, ifs: ifs)
        }
    }
}
