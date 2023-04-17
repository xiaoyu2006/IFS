import SwiftUI

class IdentifiableCGAffineTransform: Identifiable {
    var id = UUID()
    var t: CGAffineTransform
    
    init(_  t: CGAffineTransform) {
        self.t = t
    }
    
    func toPath(normalize: CGAffineTransform) -> Path {
        var shift = CGPoint(x: t.tx, y: t.ty)
        var iHat = CGPoint(x: t.a, y: t.b)
        var jHat = CGPoint(x: t.c, y: t.d)
        var ijHat = iHat + jHat
        
        iHat = iHat + shift
        jHat = jHat + shift
        ijHat = ijHat + shift
        
        shift = shift.applying(normalize)
        iHat = iHat.applying(normalize)
        jHat = jHat.applying(normalize)
        ijHat = ijHat.applying(normalize)
        return Path { path in
            path.move(to: iHat)
            path.addLine(to: shift)
            path.addLine(to: jHat)
            path.addLine(to: ijHat)
        }
    }
}

struct IFSVisualizeView: View {
    @ObservedObject var ifs: IFSSystem
    @State var size: CGSize = CGSize.zero
    @State var displayData: [IdentifiableCGAffineTransform]
    @State var depth: Int = 1
    @State var isIterating = false
    @State var uiImage: UIImage? = nil

    init(_ ifs: IFSSystem) {
        self.ifs = ifs
        self.displayData = ifs.transforms.map({ IdentifiableCGAffineTransform($0) })
    }
    
    func iterate() {
        var newDisp: [IdentifiableCGAffineTransform] = []
        for display in displayData {
            for tr in ifs.transforms {
                newDisp.append(
                    IdentifiableCGAffineTransform(tr.concatenating(display.t))
                )
            }
        }
        displayData = newDisp
        depth += 1
    }
    
    func renderPathsToImageAsync() {
        uiImage = nil
        DispatchQueue.global(qos: .background).async {
            let renderer = UIGraphicsImageRenderer(size: size)
            let normalizeTr = getUnitRecToUpsideDown(size: size)
            let image = renderer.image { ctx in
                for p in displayData {
                    let path = p.toPath(normalize: normalizeTr)
                    ctx.cgContext.addPath(path.cgPath)
                    ctx.cgContext.setFillColor(CGColor(red: 0, green: 0, blue: 1, alpha: 0.3))
                    ctx.cgContext.fillPath()
                }
            }
            DispatchQueue.main.async {
                uiImage = image
                isIterating = false
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Here you can observe how the fractal is built. Each time you click on iterate, every trapezoid is replaced by the whole image fitting in itself.").lineLimit(nil)
                
                Button("Iterate") {
                    isIterating = true
                    DispatchQueue.global(qos: .background).async {
                        iterate()
                        renderPathsToImageAsync()
                    }
                }
                .disabled(isIterating)
                Text("Depth: \(depth)")
                
                Spacer()
            }
            .frame(width: SIDEBAR_WIDTH, alignment: .leading)
            ChildSizeReader(size: $size) {
                ZoomableScrollView {
                    if let image = uiImage, !isIterating {
                        Image(uiImage: image)
                            .resizable().scaledToFit()
                    } else {
                        Text("Rendering...")
                    }
                }
            }
            .border(.black)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
            .onAppear {
                renderPathsToImageAsync()
            }
        }
    }
}
