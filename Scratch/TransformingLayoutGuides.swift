import SwiftUI
import PureSwiftUI

private let polarLayoutGuide = LayoutGuideConfig.polar(rings: 1, segments: 3)
private let gridLayoutGuide = LayoutGuideConfig.grid(columns: 3, rows: 3)
private let demoStrokeStyle = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)

struct TransformingLayoutGuides: View {
    @State private var animated = false
    
    var body: some View {
        VStack(spacing: 50) {
            Group {
                AnimatedPolarShape(animating: animated)
                    .demoStyle()
                    .layoutGuide(polarLayoutGuide)

                AnimatedGridShape(animating: animated)
                    .demoStyle()
                    .layoutGuide(gridLayoutGuide)
            }
            .frame(200)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 2)) {
                animated.toggle()
            }
        }
    }
}

private extension Shape {
    func demoStyle() -> some View {
        stroke(Color.white, style: demoStrokeStyle)
    }
}

private struct AnimatedPolarShape : Shape {
    
    var animatableData: Double
    
    init(animating: Bool) {
        self.animatableData = animating ? 1 : 0
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var g = polarLayoutGuide.layout(in: rect)
            .rotated(360.degrees, factor: animatableData)
            .scaled(1/Double.pi)
            .xOffset(from: -rect.halfWidth, to: rect.halfWidth, factor: animatableData)
        
        let transformedHeight: CGFloat = g.bottom.radiusTo(g.top)

        path.line(from: rect.leading, to: rect.trailing)
        
        g = g.yOffset(-transformedHeight * 0.5)
        
        path.ellipse(g.center, .square(transformedHeight), anchor: .center)
        
        for segment in 0..<g.yCount {
            path.line(from: g.center, to: g[1, segment])
        }
        
        return path
    }
}

private struct AnimatedGridShape : Shape {
    
    var animatableData: Double
    
    init(animating: Bool) {
        self.animatableData = animating ? 1 : 0
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let g = gridLayoutGuide.layout(in: rect)
            .scaled(1 / Double.pi)
            .rotated(360.degrees, factor: animatableData)
        
        for corner in 0..<4 {
            let lg = g
                .rotated(90.degrees * corner)
                .xOffset(from: -rect.halfWidth, to: rect.halfWidth, factor: animatableData)
            
            if (corner == 0) {
                path.move(lg.top)
            }
            
            path.line(lg[2, 0])
            path.line(lg[3, 0].to(lg[2, 1], animatableData))
            path.line(lg[3, 1])
            path.line(lg.trailing)
        }
        return path
    }
}

struct TransformingLayoutGuides_Harness: View {
    var body: some View {
        TransformingLayoutGuides()
            .greedyFrame()
            .background(Color(white: 0.1))
            .ignoresSafeArea()
            .showLayoutGuides(true)
    }
}

struct TransformingLayoutGuides_Previews: PreviewProvider {
    static var previews: some View {
        TransformingLayoutGuides_Harness()
    }
}
