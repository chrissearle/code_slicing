import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 1, lineJoin: .round)
private let shoulderRatio : CGFloat = 0.65

private let arrowLayoutConfig = LayoutGuideConfig.grid(columns: [0, 1 - shoulderRatio, shoulderRatio, 1], rows: 3)

struct AnimatedArrow: Shape {
    
    private var factor : CGFloat
    
    init(pointingRight: Bool = true) {
        factor = pointingRight ? 0 : 1
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
        
        let g = arrowLayoutConfig.layout(in: rect)
        
        path.move(g[0, 1].to(g[1, 0], factor))
        path.line(g[2, 1].to(g[1, 1], factor))
        path.line(g[2, 0].to(g[3, 1], factor))
        path.line(g.trailing)
        path.line(g[2, 3].to(g[3, 2], factor))
        path.line(g[2, 2].to(g[1, 2], factor))
        path.line(g[0, 2].to(g[1, 3], factor))
        path.line(g.leading)
        path.closeSubpath()
        
        return path
    }
}

struct AnimatedArrowDemo: View {
    @State private var pointingRight = true
    
    var body : some View {
        VStack(spacing: 50) {
            Group {
                AnimatedArrow(pointingRight: pointingRight)
                    .fill(.black)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.pointingRight.toggle()
                        }
                    }
                
                AnimatedArrow()
                    .stroke(style: strokeStyle)
                    .layoutGuide(arrowLayoutConfig)
            }
            .frame(200, 100)
        }
    }
}

struct AnimatedArrowDemo_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedArrowDemo()
            .padding()
            .previewDevice(.iPhone_SE)
            .previewSizeThatFits()
            .showLayoutGuides(true)
    }
}
