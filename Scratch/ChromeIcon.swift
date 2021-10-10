import SwiftUI
import PureSwiftUI

private let yellow: Color = .rgb8(255, 203, 66)
private let green: Color = .rgb8(14, 156, 92)
private let red: Color = .rgb8(218, 72, 59)
private let blue: Color = .rgb8(70, 135, 243)

private let outerColors = [yellow, green, red]
private let outerRadiusRatio: CGFloat = 0.73

private let innerRadiusRatio: CGFloat = 0.46

private let innerLayoutGuide = LayoutGuideConfig.polar(rings: [innerRadiusRatio], segments: 3)
private let outerLayoutGuide = LayoutGuideConfig.polar(rings: 1, segments: 3).rotated(62.7.degrees)

private let blueRadiusRatio: CGFloat = 0.37

struct ChromeIcon: View {
    var body: some View {
        GeometryReader { (geo: GeometryProxy) in
            ZStack {
                RoundedRectangle(cornerRadius: geo.widthScaled(0.2))
                    .fill(Color.white)
                
                ForEach(0..<outerColors.count) { index in
                    ZStack {
                        let sliceShape = Slice()
                            .fill(outerColors[index])
                        sliceShape
                        Shadow()
                            .fill(Color(white: 0.9))
                            .blur(geo.widthScaled(0.05))
                            .mask(sliceShape)
                            .blendMode(.multiply)
                    }
                    .rotate((120 * index).degrees)
                }
                .frame(geo.widthScaled(outerRadiusRatio))
                .layoutGuide(innerLayoutGuide, color: .black, lineWidth: 1, opacity: 1)
                .layoutGuide(outerLayoutGuide, color: .blue, lineWidth: 1, opacity: 1)
                Circle()
                    .fill(Color.white)
                    .frame(geo.widthScaled(outerRadiusRatio * innerRadiusRatio))
                Circle()
                    .fill(blue)
                    .frame(geo.widthScaled(outerRadiusRatio * blueRadiusRatio))
            }
        }
    }
}

private struct Slice : Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let gInner = innerLayoutGuide.layout(in: rect)
        let gOuter = outerLayoutGuide.layout(in: rect)
        
        path.move(rect.center)
        
        path.line(gInner[1, 0])
        path.line(gOuter[1, 0])
        path.arc(rect.center, radius: rect.halfHeight, startAngle: rect.center.angleTo(gOuter[1, 0]), delta: 120.degrees)
        path.line(gInner[1, 1])

        return path
    }
}

private struct  Shadow : Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var gInner = innerLayoutGuide.layout(in: rect)
        let gOuter = outerLayoutGuide.layout(in: rect)

        path.move(gInner[1, 0])
        path.line(gInner.top)
        path.line(gOuter[1, 0])
        
        gInner = gInner
            .rotated(48.degrees)
        
        path.line(gInner[1, 0])
        
        return path
    }
}



struct ChromeIcon_Harness : View {
    var body: some View {
        VStack(spacing: 50) {
            ForEach([400, 200, 100], id: \.self) { (size: CGFloat) in
                ChromeIcon()
                    .frame(size)
                    .showLayoutGuides(false)
            }
        }
    }
}

struct ChromeIcon_Previews: PreviewProvider {
    static var previews: some View {
        ChromeIcon_Harness()
            .padding()
            .previewSizeThatFits()
            .background(Color(white: 0.1))
    }
}
