import SwiftUI
import PureSwiftUI

private let heartColor = Color(red: 225/255, green: 40/255, blue: 48/255)
private let heartLayoutConfig = LayoutGuideConfig.grid(columns: 16, rows: 20)

private typealias Curve = (p: CGPoint, cp1: CGPoint, cp2: CGPoint)

private struct AnimatedHeart : Shape {
    let debug: Bool
    
    private var factor : CGFloat 

    init(animating: Bool, debug: Bool = false) {
        factor = animating ? 1 : 0
        self.debug = debug
    }
    
    var animatableData: CGFloat {
        get {
            factor
        }
        set {
            factor = newValue
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let g = heartLayoutConfig.layout(in: rect)
        
        let p1 = g[0, 6].to(g[2, 6], factor)
        let p2 = g[8, 4].to(g[8, 5], factor)
        let p3 = g[16, 6].to(g[14, 6], factor)
        let p4 = g[8, 20].to(g[8, 19], factor)

        var curves = [Curve]()
        
        curves.append(
            Curve(p2,
                  g[0, 0].to(g[3, 2], factor),
                  g[6, -2].to(g[7, 2], factor))
        )

        curves.append(
            Curve(p3,
                  g[10, -2].to(g[9, 2], factor),
                  g[16, 0].to(g[13, 2], factor))
        )

        curves.append(
            Curve(p4,
                  g[16, 10].to(g[15, 10], factor),
                  g[10, 14])
        )

        curves.append(
            Curve(p1,
                  g[6, 14],
                  g[0, 10].to(g[1, 10], factor))
        )
        
        path.move(to: p1)
        
        for curve in curves {
            path.curve(curve.p, cp1: curve.cp1, cp2: curve.cp2, showControlPoints: debug)
        }

        return path
    }
}

struct AnimatedHeartDemo: View {
    @State private var animating = false
    
    var body : some View {
        VStack(spacing: 50) {
            AnimatedHeart(animating: animating)
                .fill(heartColor)
                .frame(200)
            ZStack {
                AnimatedHeart(animating: animating, debug: true)
                    .stroke(Color.black, lineWidth: 2)
                    .layoutGuide(heartLayoutConfig)
                    .frame(200)
            }
        }
        .onAppear {
            withAnimation(Animation.easeOut(duration: 3).repeatForever(autoreverses: true)) {
                self.animating = true
            }
        }
    }
}

struct AnimatedHeartDemo_Previews: PreviewProvider {

    static var previews: some View {
        AnimatedHeartDemo()
            .padding(50)
            .previewDevice(.iPhone_8)
            .previewSizeThatFits()
            .showLayoutGuides(true)
    }
}
