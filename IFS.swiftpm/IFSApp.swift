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
    @State var ifs: IFSSystem = IFSSystem()
    @State var isDesignView: Bool = true
    @State var transforms = [AffineTransform(), AffineTransform()]
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
    
    var body: some View {
        VStack {
            if isDesignView {
                IFSDesignView(transforms: $transforms, size: $designerSize).padding(20)
            } else {
                IFSImageView(ifs: ifs).padding(20)
            }
            Button("Toggle Render") {
                if isDesignView {
                    let normalizeTr = getUnitRecToUpsideDown(size: designerSize).inverted()
                    let newIFS = IFSSystem()
                    for t in transforms {
                        newIFS.addTransform(
                            t.toCGAffineTransform(normalizeTr)
                        )
                    }
                    ifs = newIFS
                }
                isDesignView.toggle()
            }
        }
    }
}
