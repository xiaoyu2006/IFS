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
    }
}
