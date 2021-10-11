import SwiftUI
import PureSwiftUI

let wheelLayoutConfig = LayoutGuideConfig.polar(rings: 2, segments: 6)

private struct ConnectedWheel : Shape {
    private var factor: CGFloat
    
    var animatableData: CGFloat {
        get {
            factor
        }
        set {
            factor = newValue
        }
    }

    init(animating: Bool) {
        self.factor = animating ? 1 : 0
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = rect.minDimension * 0.5
        let yOffset = rect.halfHeight - radius
        
        let gBase = wheelLayoutConfig
            .rotated(360.degrees, factor: factor)
            .layout(in: rect)
        
        let g1 = gBase.yOffset(-yOffset)
        let g2 = gBase.yOffset(yOffset)

        let guides = [g1, g2]
        
        for g in guides {
            for segment in 0..<g.yCount {
                path.line(from: g.center, to: g[2, segment])
            }
            path.ellipse(g.center, .square(g.rect.minDimension), anchor: .center)
            path.circle(g[1, 1], radius: 10)
        }
        
        path.line(from: g1[1, 1], to: g2[1, 1])
        
        return path
    }
}

struct ConnectedWheelsDemo : View {
    @State private var animating = false
    
    var body: some View {
        VStack {
            ConnectedWheel(animating: animating)
                .stroke(Color.white, lineWidth: 3)
                .frame(200, 500)
                .layoutGuide(wheelLayoutConfig, opacity: 1)
                //.showLayoutGuides(true)
                //.border(Color(white: 0.5).opacity(0.5))
                .greedyFrame()
                .background(Color(white: 0.1))
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                        self.animating = true
                    }
                }
        }
    }
}

struct ConnectedWheelsDemo_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedWheelsDemo()
    }
}
