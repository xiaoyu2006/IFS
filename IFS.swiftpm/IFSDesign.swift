import SwiftUI

class RepresentedAffineTransform: Identifiable, ObservableObject, Equatable {
    static func == (lhs: RepresentedAffineTransform, rhs: RepresentedAffineTransform) -> Bool {
        return (
            (lhs.iHatLoc == rhs.iHatLoc) &&
            (lhs.jHatLoc == rhs.jHatLoc) &&
            (lhs.shiftLoc == rhs.shiftLoc)
        )
    }
    
    var id = UUID()
    @Published public var iHatLoc: CGPoint
    @Published public var jHatLoc: CGPoint
    @Published public var shiftLoc: CGPoint
    
    init(_ iHatLoc: CGPoint, _ jHatLoc: CGPoint, _ shift: CGPoint) {
        self.iHatLoc = iHatLoc
        self.jHatLoc = jHatLoc
        self.shiftLoc = shift
    }
    
    func from(new: CGAffineTransform, normalizeTr: CGAffineTransform) {
        let shift = CGPoint(x: new.tx, y: new.ty)
        let iHat = CGPoint(x: new.a, y: new.b) + shift
        let jHat = CGPoint(x: new.c, y: new.d) + shift
        self.iHatLoc = iHat.applying(normalizeTr)
        self.jHatLoc = jHat.applying(normalizeTr)
        self.shiftLoc = shift.applying(normalizeTr)
    }
    
    convenience init() {
        let shift = CGPoint.rand01() * 100
        let iHat = CGPoint.rand01() * 300 + shift
        let jHat = CGPoint.rand01() * 300 + shift
        self.init(iHat, jHat, shift)
    }
    
    init(from new: CGAffineTransform, normalizeTr: CGAffineTransform) {
        let shift = CGPoint(x: new.tx, y: new.ty)
        let iHat = CGPoint(x: new.a, y: new.b) + shift
        let jHat = CGPoint(x: new.c, y: new.d) + shift
        self.iHatLoc = iHat.applying(normalizeTr)
        self.jHatLoc = jHat.applying(normalizeTr)
        self.shiftLoc = shift.applying(normalizeTr)
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

extension RepresentedAffineTransforms {
    func toIFS(_ normalizeTr: CGAffineTransform) -> IFSSystem {
        let ifs = IFSSystem()
        for t in self {
            ifs.addTransform(
                t.toCGAffineTransform(normalizeTr)
            )
        }
        return ifs
    }
}

struct DraggableCircle: View {
    @Binding var location: CGPoint
    @GestureState private var startLocation: CGPoint? = nil
    @ScaledMetric(relativeTo: .body) var circleSize: CGFloat = 24
    var color: Color
    var text: String?
    
    
    var body: some View {
        Circle().fill(color)
            .frame(width: circleSize, height: circleSize)
            .contentShape(Circle().inset(by: -10))
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

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

struct AffineTransformControl: View {
    @EnvironmentObject var transform: RepresentedAffineTransform
    @GestureState var startShiftLoc: CGPoint? = nil
    @GestureState var startILoc: CGPoint? = nil
    @GestureState var startJLoc: CGPoint? = nil
    
    var color: Color
    
    var body: some View {
        DraggableCircle(location: $transform.iHatLoc, color: Color.blue, text: "i").zIndex(1000)
        DraggableCircle(location: $transform.jHatLoc, color: Color.red, text: "j").zIndex(1000)
        DraggableCircle(location: $transform.shiftLoc, color: Color.black, text: "O").zIndex(1000)
        Path { path in
            path.move(to: transform.iHatLoc)
            path.addLine(to: transform.shiftLoc)
            path.addLine(to: transform.jHatLoc)
            let ijHat = (transform.iHatLoc - transform.shiftLoc) + (transform.jHatLoc - transform.shiftLoc)
            path.addLine(to: transform.shiftLoc + ijHat)
        }
        .fill(color)
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
        .zIndex(-1000)
    }
}

struct IFSDesignView: View {
    @Binding var transforms: RepresentedAffineTransforms
    @Binding var size: CGSize
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Transforms are the heart of IFS. A transform includes rotations, translations and resizing. It can be visualized as a trapezoid, where each point of the unit square is mapped into that trapezoid.").lineLimit(nil)
                
                Image("Tr").resizable().scaledToFit()
                
                Text("The default IFS design is exactly the Sierpiński triangle.")
                
                Text("Use `Clear` / `Add Transform` buttons and the draggable circles to help you design your *own* IFS. Note that **O** to **i** is the original bottom of the image and **O** to **j** is the original left side of the image.").lineLimit(nil)
                
                Text("When you're done, click on **Next**.")
                
                HStack {
                    Button {
                        transforms.append(RepresentedAffineTransform())
                    } label: {
                        Text("**Add Transform**")
                    }
                    Spacer()
                    Button("Clear") {
                        transforms.removeAll()
                        transforms.append(RepresentedAffineTransform())
                    }
                    Spacer(minLength: 5)
                }
                
                Spacer()
            }
            .frame(width: SIDEBAR_WIDTH, alignment: .leading)
            ChildSizeReader(size: $size) {
                ZStack {
                    ForEach(transforms) { t in
                        AffineTransformControl(color: Color(red: 0, green: 1, blue: 0, opacity: 0.1))
                            .environmentObject(t)
                    }
                }
            }
            .border(.black)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
        }
    }
}
