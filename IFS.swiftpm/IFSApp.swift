import SwiftUI

@main
struct IFSApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.light)
        }
    }
}


struct MainView: View {
    enum Displaying {
        case design, visualize, image
    }
    
    @State var ifs: IFSSystem = IFSSystem()
    @State var currentView: Displaying = .design
    @State var transforms = [RepresentedAffineTransform(), RepresentedAffineTransform()]
    @State var designerSize: CGSize = CGSize.zero
    
    //        ifs = IFSSystem()
    //        ifs.addTransform(
    //            CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
    //                              jHat: CGPoint(x: 0, y: 0.5),
    //                              shift: CGPoint.zero))
    //        ifs.addTransform(
    //            CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
    //                              jHat: CGPoint(x: 0, y: 0.5),
    //                              shift: CGPoint(x: 0.5, y: 0)))
    //        ifs.addTransform(
    //            CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
    //                              jHat: CGPoint(x: 0, y: 0.5),
    //                              shift: CGPoint(x: 0.25, y: 0.433)), weight: 2)
    
    func updateIFS() {
        let normalizeTr = getUnitRecToUpsideDown(size: designerSize).inverted()
        let newIFS = IFSSystem()
        for t in transforms {
            newIFS.addTransform(
                t.toCGAffineTransform(normalizeTr)
            )
        }
        ifs = newIFS
    }
    
    var body: some View {
        VStack {
            switch currentView {
            case .design:
                IFSDesignView(transforms: $transforms, size: $designerSize).padding(20)
            case .visualize:
                IFSVisualizeView(ifs).padding(20)
            case .image:
                IFSImageView(ifs: ifs).padding(20)
            }
            HStack {
                Button("Design") {
                    currentView = .design
                }
                Button("Visualize") {
                    updateIFS()
                    currentView = .visualize
                }
                Button("Image") {
                    updateIFS()
                    currentView = .image
                }
            }
        }
    }
}
