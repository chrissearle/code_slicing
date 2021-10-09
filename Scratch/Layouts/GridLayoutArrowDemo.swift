import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 1, lineJoin: .round)
private let shoulderRatio : CGFloat = 0.65

private let arrowLayoutConfig = LayoutGuideConfig.grid(columns: [0, shoulderRatio, 1], rows: 3)

struct ArrowNative: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let shoulderX = rect.minX + (rect.width * shoulderRatio)
        let rowHeight = rect.height / 3
        let row1Y = rect.minY + rowHeight
        let row2Y = row1Y + rowHeight
        
        path.move(to: CGPoint(x: rect.minX, y: row1Y))
        path.addLine(to: CGPoint(x: shoulderX, y: row1Y))
        path.addLine(to: CGPoint(x: shoulderX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: shoulderX, y: rect.maxY))
        path.addLine(to: CGPoint(x: shoulderX, y: row2Y))
        path.addLine(to: CGPoint(x: rect.minX, y: row2Y))
        path.closeSubpath()
        
        return path
    }
}

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var g = arrowLayoutConfig.layout(in: rect)
        
        path.move(g[0, 1])
        path.line(g[1, 1])
        path.line(g[1, 0])
        path.line(g.trailing)
        path.line(g[1, 3])
        path.line(g[1, 2])
        path.line(g[0, 2])
        path.closeSubpath()
        
        return path
    }
}

struct GridLayoutArrowDemo: View {
    var body: some View {
        VStack(spacing: 50) {
            Group {
                ArrowNative()
                    .stroke(style: strokeStyle)
                    .border(Color.black.opacity(0.2))
                Arrow()
                    .stroke(style: strokeStyle)
                    .layoutGuide(arrowLayoutConfig)
            }
            .frame(200, 100)
        }
    }
}

struct GridLayoutArrowDemo_Previews: PreviewProvider {
    static var previews: some View {
        GridLayoutArrowDemo()
            .padding()
            .previewSizeThatFits()
            .showLayoutGuides(true)
    }
}
