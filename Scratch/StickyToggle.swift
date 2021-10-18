import SwiftUI
import PureSwiftUI

private let toggleLayoutConfig = LayoutGuideConfig.grid(columns: 10, rows: 10)

private let springAnimation = Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 1)

private let colorAnimation = Animation.easeInOut(duration: 0.25)

struct StickyToggle: View {
    let size: CGFloat
    let stickyThreshold: CGFloat
    
    @State private var stuck = true
    @State private var atTop = true
    @State private var potentiallyAtTop = true
    @State private var yTranslation = CGFloat.zero
    @State private var halfViewHeight = CGFloat.zero
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
        
        if (stuck) {
            return yTranslation / 2
        } else {
            return yTranslation
        }
    }
    
    private var scaleForTranslation : CGFloat {
        guard stuck && validTranslation else {
            return 1
        }

        return 1 + absoluteTranslation / size
    }

    private var absoluteTranslation : CGFloat {
        abs(yTranslation)
    }
    
    private var stretchFactor : CGFloat {
        guard stuck && validTranslation else {
            return 0
        }

        let distanceToThreshold = stickyThreshold - absoluteTranslation
        
        let normalizedDistanceToThreshold = distanceToThreshold / stickyThreshold
        
        return 1 - normalizedDistanceToThreshold
    }

    var body: some View {
        let designing = false
        let debug = false
        GeometryReader { (geo: GeometryProxy) in
            ZStack {
                VStack {
                    StretchableSquare(stretchFactor: stretchFactor, atTop: atTop, designing: designing)
                        .toggleStyle(color: potentiallyAtTop ? .green : .red, designing: designing)
                        .frameIfNot(designing, size)
                        .frameIf(designing, geo.widthScaled(0.9))
                        .yScale(scaleForTranslation)
                        .yOffset(offsetForTranslation)
                        .yOffsetIfNot(atTop, offsetAtBottom)
                        .shadowIfNot(designing, radius: 10)
                        .layoutGuide(toggleLayoutConfig)
                        .showLayoutGuides(designing)
                        .gesture(DragGesture(minimumDistance: 0)
                                    .onChanged(onChanged)
                                    .onEnded(onEnded))
                    if (!designing) {
                        Spacer()
                    }
                }
                .onAppear {
                    halfViewHeight = geo.heightScaled(0.5)
                    offsetAtBottom = geo.height - size
                }
                
                if debug && !designing {
                    VStack {
                        TitleText("atTop: \(atTop)")
                        TitleText("potentiallyAtTop: \(potentiallyAtTop)")
                        TitleText("stuck: \(stuck)")
                        TitleText("stretchFactor: \(stretchFactor)")
                    }
                    .animation(nil)
                }
            }
            .greedyFrame()
        }
    }
    
    private func inTopHalf(_ gesture: DragGesture.Value) -> Bool {
        gesture.location.y <= halfViewHeight
    }
    
    private func onChanged(_ gesture: DragGesture.Value) {
        yTranslation = gesture.translation.y
        if (stuck) {
            withAnimation(springAnimation) {
                stuck = absoluteTranslation < stickyThreshold
            }
        }
        withAnimation(colorAnimation) {
            potentiallyAtTop = inTopHalf(gesture)
        }
    }

    private func onEnded(_ gesture: DragGesture.Value) {
        withAnimation(springAnimation) {
            yTranslation = .zero
            stuck = true
            atTop = inTopHalf(gesture)
        }
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
    private let atTop: Bool
    
    var animatableData: CGFloat

    init(stretchFactor: CGFloat, atTop: Bool, designing: Bool) {
        animatableData = stretchFactor
        self.designing = designing
        self.atTop = atTop
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let g = toggleLayoutConfig.layout(in: rect)
            .yScaled(-1, factor: atTop || designing ? 0 : 1)
        
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
