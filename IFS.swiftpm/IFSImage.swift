import SwiftUI

struct IFSImageView: View {
    @ObservedObject public var ifs: IFSSystem
    @State var size = CGSize.zero
    @State public var chaosSamples = 40000
    @State public var sliderValue: Double = 40000
    @State public var isGalleryPresent: Bool = false
    
    public var diameter: CGFloat = 5.0
    let upscaling: CGFloat = 4
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("**Congrats!** You have successfully created your fractal! You can save it to your album when it's rendered.").lineLimit(nil)
                Text("Pinch to zoom in on the image. You can find the fractal repeating itself, just on a smaller scale.").lineLimit(nil)
                
                Button("Save Image") {
                    if let image = uiImage {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }
                
                Text("The render section utilizes a random-based algorithm that efficiently generates fractals without consuming excessive resources. Adjust the sample slider below to optimize your fractal's quality. Keep in mind that higher sample sizes will increase rendering time.").lineLimit(nil)
                
                Slider(
                    value: $sliderValue,
                    in: 10000...80000,
                    step: 5000
                ) {
                    Text("Samples")
                } minimumValueLabel: {
                    Text("10k")
                } maximumValueLabel: {
                    Text("80k")
                } onEditingChanged: { isEditing in
                    if uiImage != nil && !isEditing {
                        chaosSamples = Int(sliderValue)
                        renderImageAsync(size: size)
                    }
                }.disabled(uiImage == nil)
                
                Text("Samples: \(chaosSamples)")
                                
                Group {
                    Text("Are you up for a challenge? Explore our gallery of fractals, each of which can be described using an iterated function system. Give your artistic skills a workout and start drawing them out now!").lineLimit(nil)
                    
                    Button("Gallery") {
                        isGalleryPresent = true
                    }
                    .sheet(isPresented: $isGalleryPresent) {
                        ScrollView {
                            VStack(spacing: 30) {
                                Text("Gallery").font(.largeTitle)
                                Image("Koch").resizable().scaledToFit().padding(10)
                                Text("Von Koch Curve")
                                Image("YiFr").resizable().scaledToFit().padding(10)
                                Text("Some random fracal I came up with")
                                Image("Tree").resizable().scaledToFit().padding(10)
                                Text("A weird tree (As a bonus question)")
                            }.padding(30)
                        }
                    }
                    
                    Text("Get creative and craft your own fractals. In case of any hiccups, refer to the visualization section for assistance. Click on **Previous** to start producing your own unique masterpieces.").lineLimit(nil)
                }
                
                Spacer()
            }
            .frame(width: SIDEBAR_WIDTH, alignment: .leading)
            Group {
                ChildSizeReader(size: $size) {
                    ZoomableScrollView {
                        if let image = uiImage {
                            Image(uiImage: image)
                                .resizable().scaledToFit()
                        } else {
                            Text("Rendering...")
                                .frame(width: size.width, height: size.height)
                        }
                    }
                    .border(.black)
                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                    .onAppear {
                        renderImageAsync(size: size)
                    }
                }
            }
        }
    }
    
    private func renderImageAsync(size: CGSize) {
        uiImage = nil
        DispatchQueue.global(qos: .background).async {
            let renderSize = CGSize(width: size.width * upscaling, height: size.height * upscaling)
            
            func drawDot(in context: CGContext, at point: CGPoint, withColor color: CGColor, diameter: CGFloat) {
                let rect = CGRect(x: point.x - diameter/2, y: point.y - diameter/2, width: diameter, height: diameter)
                context.setFillColor(color)
                context.fillEllipse(in: rect)
            }
            
            let renderer = UIGraphicsImageRenderer(size: renderSize)
            let normalizeTr = getUnitRecToUpsideDown(size: renderSize)
            
            let image = renderer.image { ctx in
                print("Rendering \(chaosSamples)")
                for _ in 0 ..< chaosSamples {
                    var p = ifs.chaosGameStep()
                    p.0 = p.0.applying(normalizeTr)
                    drawDot(in: ctx.cgContext, at: p.0, withColor: p.1, diameter: 6)
                }
            }
            
            DispatchQueue.main.async {
                uiImage = image
            }
        }
    }
}
