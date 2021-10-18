import SwiftUI
import PureSwiftUI

private let toggleLayoutConfig = LayoutGuideConfig.grid(columns: 10, rows: 10)

struct StickyToggle: View {
    let debug = false
    
    var body: some View {
        StretchableSquare(stretchFactor: 0, isTop: true, debug: debug)
            .toggleStyle(color: .green, debug: debug)
            .frame(360)
            .shadowIfNot(debug, radius: 10)
            .layoutGuide(toggleLayoutConfig)
            .showLayoutGuides(debug)
    }
}

private extension Shape {
    @ViewBuilder func toggleStyle(color: Color, debug: Bool) -> some View {
        if (debug) {
            stroke(Color.black, style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
        } else {
            fill(color)
        }
    }
}

private struct StretchableSquare : Shape {
    var debug: Bool
    var isTop: Bool
    var animatableData: CGFloat

    init(stretchFactor: CGFloat, isTop: Bool, debug: Bool) {
        animatableData = stretchFactor
        self.debug = debug
        self.isTop = isTop
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let g = toggleLayoutConfig.layout(in: rect)
            .rotated(180.degrees, factor: isTop ? 0 : 1)
        
        let p1 = g.topLeading
        let p2 = g.topTrailing
        let cp2p3 = g[10, 1].to(g[6, 1], animatableData)
        let p3 = g.bottomTrailing.to(g[6, 10], animatableData)
        let p4 = g.bottomLeading.to(g[4 , 10], animatableData)
        let cp2p1 = g[0, 1].to(g[4, 1], animatableData)
        
        path.move(p1)
        path.line(p2)
        
        path.quadCurve(p3, cp: cp2p3, showControlPoints: debug)
        
        path.line(p4)
        
        path.quadCurve(p1, cp: cp2p1, showControlPoints: debug)

        
        return path
    }
}


struct StickyToggle_Harness : View {
    var body: some View {
        VStack {
            StickyToggle()
        }
    }
}

struct StickyToggle_Previews: PreviewProvider {
    static var previews: some View {
        StickyToggle_Harness()
            .previewDevice(.iPhone_8_Plus)
    }
}
