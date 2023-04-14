import SwiftUI

extension CGAffineTransform {
    init(iHat: CGPoint, jHat: CGPoint, shift: CGPoint) {
        self.init(iHat.x, iHat.y, jHat.x, jHat.y, shift.x, shift.y)
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func rand01() -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1))
    }
}

func getUnitRecTo(size: CGSize) -> CGAffineTransform {
    let width = size.width
    let height = size.height
    let imageWH = min(width, height)
    
    let shift: CGPoint
    if width > height {
        // -----------------
        // |   |       |   |
        // |   | Squ-  |   |
        // |   ^ are   |   |
        // |   |       |   |
        // O-------->-------
        shift = CGPoint(x: (width - imageWH) / 2, y: 0)
    } else {
        shift = CGPoint(x: 0, y: (height - imageWH) / 2)
    }
    
    return CGAffineTransform(iHat: CGPoint(x: imageWH, y: 0), jHat: CGPoint(x: 0, y: imageWH), shift: shift)
}

func getUnitRecToUpsideDown(size: CGSize) -> CGAffineTransform {
    let width = size.width
    let height = size.height
    let imageWH = min(width, height)
    
    let shift: CGPoint
    if width >= height {
        // O----------------
        // |   |       |   |
        // |   | Squ-  |   |
        // |   ^ are   |   |
        // |   |       |   |
        // --------->-------
        shift = CGPoint(x: (width - imageWH) / 2, y: height)
    } else {
        shift = CGPoint(x: 0, y: (height - imageWH) / 2 + imageWH)
    }
    
    return CGAffineTransform(iHat: CGPoint(x: imageWH, y: 0), jHat: CGPoint(x: 0, y: -imageWH), shift: shift)
}

// https://stackoverflow.com/a/60861575/10811334
struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

// https://stackoverflow.com/a/64110231/10811334
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        
        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        scrollView.addSubview(hostedView)
        
        return scrollView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    
    // Coordinator
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}

