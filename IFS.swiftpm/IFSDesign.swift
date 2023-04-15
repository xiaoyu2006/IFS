import SwiftUI

class RepresentedAffineTransform: Identifiable, ObservableObject {
    var id = UUID()
    @Published public var iHatLoc: CGPoint
    @Published public var jHatLoc: CGPoint
    @Published public var shiftLoc: CGPoint
    
    init(_ iHatLoc: CGPoint, _ jHatLoc: CGPoint, _ shift: CGPoint) {
        self.iHatLoc = iHatLoc
        self.jHatLoc = jHatLoc
        self.shiftLoc = shift
    }
    
    convenience init() {
        let shift = CGPoint.rand01() * 100
        let iHat = CGPoint.rand01() * 300 + shift
        let jHat = CGPoint.rand01() * 300 + shift
        self.init(iHat, jHat, shift)
    }
    
    func toCGAffineTransform(_ normalize: CGAffineTransform) -> CGAffineTransform {
        let iHatNorm: CGPoint = iHatLoc.applying(normalize)
        let jHatNorm: CGPoint = jHatLoc.applying(normalize)
        let shiftNorm: CGPoint = shiftLoc.applying(normalize)
        return CGAffineTransform(
            // Location to scaling factor
            iHat: iHatNorm - shiftNorm,
            jHat: jHatNorm - shiftNorm,
            shift: shiftNorm)
    }
}

typealias RepresentedAffineTransforms = [RepresentedAffineTransform]

struct DraggableCircle: View {
    @Binding var location: CGPoint
    @GestureState private var startLocation: CGPoint? = nil
    @ScaledMetric(relativeTo: .body) var circleSize: CGFloat = 24
    var color: Color
    var text: String?
    
    
    var body: some View {
        Circle().fill(color)
            .frame(width: circleSize, height: circleSize)
            .position(location)
            .gesture(DragGesture()
                .onChanged { value in
                    var newLocation = startLocation ?? location
                    newLocation.x += value.translation.width
                    newLocation.y += value.translation.height
                    self.location = newLocation
                }.updating($startLocation) { (value, startLocation, transaction) in
                    startLocation = startLocation ?? location
                })
        if let t = text {
            Text(t).foregroundColor(Color.white).position(location)
        }
    }
}

struct AffineTransformControl: View {
    @EnvironmentObject var transform: RepresentedAffineTransform
    @GestureState var startShiftLoc: CGPoint? = nil
    @GestureState var startILoc: CGPoint? = nil
    @GestureState var startJLoc: CGPoint? = nil
    
    var color: Color
    
    var body: some View {
        DraggableCircle(location: $transform.iHatLoc, color: Color.blue, text: "i")
        DraggableCircle(location: $transform.jHatLoc, color: Color.red, text: "j")
        DraggableCircle(location: $transform.shiftLoc, color: Color.black)
        Path { path in
            path.move(to: transform.iHatLoc)
            path.addLine(to: transform.shiftLoc)
            path.addLine(to: transform.jHatLoc)
            let ijHat = (transform.iHatLoc - transform.shiftLoc) + (transform.jHatLoc - transform.shiftLoc)
            path.addLine(to: transform.shiftLoc + ijHat)
        }
        .fill(color)
        .zIndex(-1000)
        .gesture(DragGesture()
            .onChanged { value in
                let t = value.location - value.startLocation
                transform.shiftLoc = (startShiftLoc ?? transform.shiftLoc) + t
                transform.iHatLoc = (startILoc ?? transform.iHatLoc) + t
                transform.jHatLoc = (startJLoc ?? transform.jHatLoc) + t
            }.updating($startShiftLoc) { (value, state, transaction) in
                state = state ?? transform.shiftLoc
            }.updating($startILoc) { (value, state, transaction) in
                state = state ?? transform.iHatLoc
            }.updating($startJLoc) { (value, state, transaction) in
                state = state ?? transform.jHatLoc
            })
    }
}

struct IFSDesignView: View {
    @Binding var transforms: RepresentedAffineTransforms
    @Binding var size: CGSize
    
    var body: some View {
        HStack {
            ChildSizeReader(size: $size) {
                ForEach(transforms){ t in
                    AffineTransformControl(color: Color(red: 0, green: 1, blue: 0, opacity: 0.1))
                        .environmentObject(t)
                }
            }
            .border(.black)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
            VStack {
                Button("Add Transform") {
                    transforms.append(RepresentedAffineTransform())
                }
                Button("Clear") {
                    transforms.removeAll()
                    transforms.append(RepresentedAffineTransform())
                }
//                ForEach(transforms) { t in
//                    Text(
//                        "\(t.toCGAffineTransform(getUnitRecToUpsideDown(size: size)))"
//                    )
//                }
            }
        }
    }
}
