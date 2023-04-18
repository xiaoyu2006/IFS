import SwiftUI
import Steps

@main
struct IFSApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.light)
        }
    }
}

let SIDEBAR_WIDTH: CGFloat = 300

struct BasicInstructionsView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Iterated Function System").lineLimit(nil).font(.largeTitle)
                Text("You may recognize the image below, known as the Sierpiński triangle, which is named after the prominent Polish mathematician Wacław Sierpiński.").lineLimit(nil)
                Image("Sierpinski", label: Text("Sierpinski")).resizable().padding(10).scaledToFit()
                Text("One of its significant properties is that it's a fractal: the image is self-similar to itself. If you zoom in on the triangle, you'll get exactly itself.").lineLimit(nil)
                Text("An Iterated Function System (IFS) is a method for creating such fractals by repeatedly applying a set of functions such as scaling, rotation, or translation to itself. The resulting shape is the union of all the transformed copies of the initial shape.").lineLimit(nil)
                Text("IFSs can be used to create a wide variety of fractals, including the Sierpiński triangle, the Koch snowflake, and the Barnsley fern. The Sierpiński triangle can be described using the following IFS:").lineLimit(nil)
                Image("Attempt").resizable().scaledToFit().scaleEffect(0.8)
                Text("Let's get started!")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(30)
    }
}

struct MainView: View {
    struct Item {
        var title: String
        var image: Image?
        var display: Displaying
    }
    
    enum Displaying {
        case design, visualize, image
    }
    
    @State var currentView: Displaying = .design
    @State var transforms = [RepresentedAffineTransform(), RepresentedAffineTransform()]
    @State var designerSize: CGSize = CGSize.zero
    @State var isInstructionsPresented = true
    
    func getIFS() -> IFSSystem {
        let normalizeTr = getUnitRecToUpsideDown(size: designerSize).inverted()
        return transforms.toIFS(normalizeTr)
    }
    
    @ObservedObject private var stepsState: StepsState<Item>
    
    init() {
        let items = [
            Item(title: "Design", image: Image(systemName: "wind"), display: .design),
            Item(title: "Visualization", image: Image(systemName: "tornado"), display: .visualize),
            Item(title: "Render", image: Image(systemName: "hurricane"), display: .image)
        ]
        stepsState = StepsState(data: items)
    }
    
    func onCreateStep(_ item: Item) -> Step {
        return Step(title: item.title, image: item.image)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Steps(state: stepsState, onCreateStep: onCreateStep)
            
            HStack(spacing: 60) {
                Button("Previous") {
                    self.stepsState.previousStep()
                }.disabled(!self.stepsState.hasPrevious)
                Button("Next") {
                    self.stepsState.nextStep()
                }.disabled(
                    // Nasty hack
                    self.stepsState.currentIndex == 2
                )
            }
            
            Group {
                switch stepsState.currentIndex {
                case 0:
                    IFSDesignView(transforms: $transforms, size: $designerSize).padding(20)
                case 1:
                    IFSVisualizeView(getIFS()).padding(20)
                default:
                    IFSImageView(ifs: getIFS()).padding(20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $isInstructionsPresented) {
            BasicInstructionsView(isPresented: $isInstructionsPresented).preferredColorScheme(.light)
        }
        .onChange(of: designerSize) { _ in
            let tr1 = CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
                                        jHat: CGPoint(x: 0, y: 0.5),
                                        shift: CGPoint.zero)
            let tr2 = CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
                                        jHat: CGPoint(x: 0, y: 0.5),
                                        shift: CGPoint(x: 0.5, y: 0))
            let tr3 = CGAffineTransform(iHat: CGPoint(x: 0.5, y: 0),
                                        jHat: CGPoint(x: 0, y: 0.5),
                                        shift: CGPoint(x: 0.25, y: 0.433))
            let normalizeTr = getUnitRecToUpsideDown(size: designerSize)
            let rTr1 = RepresentedAffineTransform(from: tr1, normalizeTr: normalizeTr)
            let rTr2 = RepresentedAffineTransform(from: tr2, normalizeTr: normalizeTr)
            let rTr3 = RepresentedAffineTransform(from: tr3, normalizeTr: normalizeTr)
            transforms = [rTr1, rTr2, rTr3]
        }
    }
}
