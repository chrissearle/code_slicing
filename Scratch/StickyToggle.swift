import SwiftUI
import PureSwiftUI

private let toggleLayoutConfig = LayoutGuideConfig.grid(columns: 10, rows: 10)

struct StickyToggle: View {
    let size: CGFloat
    let stickyThreshold: CGFloat
    
    @State private var atTop = true
    @State private var yTranslation = CGFloat.zero
    @State private var halfScreenHeight = CGFloat.zero
    @State private var offsetAtBottom = CGFloat.zero
    
    private var validTranslation: Bool {
        (atTop && yTranslation > 0)
        ||
        (!atTop && yTranslation < 0)
    }

    private var offsetForTranslation: CGFloat {
        guard validTranslation else  {
            return 0
        }
        
        return yTranslation
    }
    
    var body: some View {
        let designing = false
        let debug = true
        GeometryReader { (geo: GeometryProxy) in
            ZStack {
                VStack {
                    StretchableSquare(stretchFactor: 0, isTop: true, designing: designing)
                        .toggleStyle(color: .green, designing: designing)
                        .frame(size)
                        .yOffset(offsetForTranslation)
                        .yOffsetIfNot(atTop, offsetAtBottom)
                        .shadowIfNot(designing, radius: 10)
                        .layoutGuide(toggleLayoutConfig)
                        .showLayoutGuides(designing)
                        .gesture(DragGesture(minimumDistance: 0)
                                    .onChanged(onChanged)
                                    .onEnded(onEnded))
                    Spacer()
                }
                .onAppear {
                    halfScreenHeight = geo.heightScaled(0.5)
                    offsetAtBottom = geo.height - size
                }
                
                if debug && !designing {
                    TitleText("atTop: \(atTop)")
                }
            }
            .greedyFrame()
        }
    }
    
    private func isTopHalf(_ gesture: DragGesture.Value) -> Bool {
        gesture.location.y <= halfScreenHeight
    }
    
    private func onChanged(_ gesture: DragGesture.Value) {
        yTranslation = gesture.translation.y
    }

    private func onEnded(_ gesture: DragGesture.Value) {
        yTranslation = .zero
        
        atTop = isTopHalf(gesture)
    }

}

private extension Shape {
    @ViewBuilder func toggleStyle(color: Color, designing: Bool) -> some View {
        if (designing) {
            stroke(Color.black, style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
        } else {
            fill(color)
        }
    }
}

private struct StretchableSquare : Shape {
    private let designing: Bool
    private let isTop: Bool
    
    var animatableData: CGFloat

    init(stretchFactor: CGFloat, isTop: Bool, designing: Bool) {
        animatableData = stretchFactor
        self.designing = designing
        self.isTop = isTop
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let g = toggleLayoutConfig.layout(in: rect)
            .yScaled(-1, factor: isTop || designing ? 0 : 1)
        
        let p1 = g.topLeading
        let p2 = g.topTrailing
        let cp2p3 = g[10, 1].to(g[6, 1], animatableData)
        let p3 = g.bottomTrailing.to(g[6, 10], animatableData)
        let p4 = g.bottomLeading.to(g[4 , 10], animatableData)
        let cp2p1 = g[0, 1].to(g[4, 1], animatableData)
        
        path.move(p1)
        path.line(p2)
        
        path.quadCurve(p3, cp: cp2p3, showControlPoints: designing)
        
        path.line(p4)
        
        path.quadCurve(p1, cp: cp2p1, showControlPoints: designing)

        
        return path
    }
}


struct StickyToggle_Harness : View {
    var body: some View {
        VStack {
            GeometryReader { (geo: GeometryProxy) in
                StickyToggle(size: geo.widthScaled(0.3), stickyThreshold: geo.heightScaled(0.3))
            }
            .ignoresSafeArea()
        }
    }
}

struct StickyToggle_Previews: PreviewProvider {
    static var previews: some View {
        StickyToggle_Harness()
            .previewDevice(.iPhone_8_Plus)
    }
}
