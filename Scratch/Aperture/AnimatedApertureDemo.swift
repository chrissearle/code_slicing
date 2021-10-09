import SwiftUI
import PureSwiftUI

private let bladeLayoutConfig = LayoutGuideConfig.grid(columns: 10, rows: 10)

struct AnimatedApertureDemo: View {
    let debug: Bool
    
    let numBlades : Int
    
    @State private var animating = false
    
    init(numBlades: Int = 9, debug: Bool = false) {
        self.debug = debug
        self.numBlades = debug ? 1 : numBlades
    }
    
    var body: some View {
        ZStack {
            ForEach (0..<numBlades) { currentBlade in
                ApertureBlade(animating: self.animating, numBlades: self.numBlades,  currentBlade: currentBlade, debug: self.debug)
                    .bladeStyle(debug: self.debug)
            }
        }
        .frame(150)
        .layoutGuide(bladeLayoutConfig)
        .showLayoutGuides(debug)
        .apertureStyle(debug: debug)
        .greedyFrame()
        .backgroundIfNot(debug, LinearGradient([Color(white: 0.8), Color(white: 0.1)], to: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                self.animating = true
            }
        }
    }
}

private struct ApertureBlade : Shape {
    let currentBlade: Int
    let stepAngle: Angle
    let debug: Bool
    
    var factor: Double
    
    var animatableData: Double {
        get {
            factor
        }
        set {
            factor = newValue
        }
    }
    
    init(factor: Double, numBlades: Int = 9, currentBlade: Int, debug: Bool = false) {
        self.debug = debug
        self.currentBlade = currentBlade
        self.stepAngle = (360 / numBlades.asDouble).degrees
        self.factor = factor
    }
    
    init(animating: Bool, numBlades: Int = 9, currentBlade: Int, debug: Bool = false) {
        self.init(factor: animating ? 1 : 0, numBlades: numBlades, currentBlade: currentBlade, debug: debug)
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var g = bladeLayoutConfig.layout(in: rect)
        
        if (!debug) {
            g = g.rotated(from: -12.degrees, to: 28.degrees, anchor: .top, factor: factor)
                .xOffset(rect.widthScaled(-0.3))
                .rotated(stepAngle * currentBlade)
                .rotated(90.degrees, factor: factor)
        }
        
        path.move(g.top)
        
        path.curve(g[10, 8], cp1: g[5, 4], cp2: g[6, 7], showControlPoints: debug)
        path.curve(g[2, 0], cp1: g[5, 8], cp2: g[1, 5], showControlPoints: debug)
        
        path.line(g.top)
        
        return path
    }
}

private extension Shape {
    @ViewBuilder func bladeStyle(debug: Bool = false) -> some View {
        if debug {
            self
                .stroke(Color.black, lineWidth: 2)
        } else {
            self
                .fill(LinearGradient([.red, .yellow], to: .bottomTrailing))
                .overlay(self.stroke(Color.black, style: .init(lineWidth: 1, lineJoin: .round)))
                .shadow(5)
        }
    }
}

private extension View {
    @ViewBuilder func apertureStyle(debug: Bool = false) -> some View {
        if debug {
            self
        } else {
            backgroundColor(.white)
                .overlay(Circle()
                        .inset(by: -10)
                        .stroke(.white, lineWidth: -10)
                        .shadowColor(.black, 10)
            )
                .clipCircle()
            
            
        }
    }
}

struct AnimatedApertureDemo_Previews: PreviewProvider {
    struct AnimatedApertureDemo_Harness: View {
        var body: some View {
            AnimatedApertureDemo(debug: false)
        }
    }
    
    
    static var previews: some View {
        AnimatedApertureDemo_Harness()
    }
}

