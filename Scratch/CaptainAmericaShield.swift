import SwiftUI
import PureSwiftUI

private func createColor(_ red: Double, _ green: Double, _ blue: Double) -> Color {
    Color(red: red/255, green: green/255, blue: blue/255)
}

private let colorShieldSilver = createColor(211, 221, 234)
private let colorShieldBlue = createColor(22, 68, 146)
private let colorShieldRed = createColor(224, 22, 26)

private let diameter : CGFloat = UIScreen.mainSize.minDimension - 50
private let diameterDeltaPerRing = diameter * 0.2
private let starSize = diameter * 0.4
private let starDetailingSize = starSize * 0.9

private let starLayoutConfig = LayoutGuideConfig.polar(rings: 1, segments: 5)
private let starDetailingLayoutConfig = LayoutGuideConfig.polar(rings: [0.38, 1], segments: 10)

private let conicHighlights: AngularGradient = {
    var stops : [Gradient.Stop] = []
    
    let halfHighlightRadialWidth: CGFloat = 0.1
    let colorDark = Color(white: 0.5)
    
    for index in 0...4 {
        let offset = (index.asDouble * 0.25).asCGFloat
        stops.append(.init(color: colorDark, location: offset - halfHighlightRadialWidth))
        stops.append(.init(color: .white, location: offset))
        stops.append(.init(color: colorDark, location: offset + halfHighlightRadialWidth))
    }
    
    return AngularGradient(gradient: Gradient(stops: stops), center: .center)
}()

private func normalizeValue(_ value: Double) -> Double {
    diameter * (value / 400)
}

struct CaptainAmericaShield: View {
    @State private var rotating = false
    
    var body: some View {
        ZStack {
            SizedCircleWithColor(diameter, colorShieldRed)
            SizedCircleWithColor(diameter - diameterDeltaPerRing, colorShieldSilver)
            SizedCircleWithColor(diameter - (2*diameterDeltaPerRing), colorShieldRed)
            SizedCircleWithColor(starSize, colorShieldBlue)
            
            Group {
                ShieldStar()
                    .fillColor(colorShieldSilver)
                    .frame(starSize)
                    //.layoutGuide(starLayoutConfig, color: .green, lineWidth: 2)

                StarDetailing()
                    .stroke(Color.black, lineWidth: normalizeValue(0.5))
                    .frame(starDetailingSize)
                    .blur(normalizeValue(0.75))
                    //.layoutGuide(starDetailingLayoutConfig, color: .green, lineWidth: 2)

                StarDetailing()
                    .stroke(Color(white:0.95), lineWidth: normalizeValue(0.75))
                    .frame(starDetailingSize)
                    .blur(normalizeValue(0.3))
            }
            .rotateIf(rotating, 360.degrees )
            
            BrushedOverlay()
                .strokeColor(.gray, lineWidth: normalizeValue(0.1))
                .blur(normalizeValue(0.5))
                .blendMode(.multiply)
            
            Circle()
                .fill(conicHighlights)
                .blur(normalizeValue(4))
                .overlay(Circle()
                            .fillColor(.white)
                            .frame(normalizeValue(15))
                            .blur(normalizeValue(6)))
                .rotate(10.degrees)
                .drawingGroup()
                .blendMode(.multiply)
        }
        .frame(diameter)
        .clipCircle()
        .onAppear {
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                self.rotating = true
            }
        }
    }
}

struct SizedCircleWithColor: View {
    let size: CGFloat
    let color: Color
    
    init(_ size : CGFloat, _ color: Color) {
        self.size = size
        self.color = color
    }
    
    var body : some View {
        Circle()
            .fillColor(color)
            .frame(size)
    }
}

private struct ShieldStar : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var g = starLayoutConfig.layout(in: rect)
        
        path.move(g[1, 0])
        
        for segment in 1..<g.yCount {
            path.line(g[1, segment * 2])
        }

        path.closeSubpath()
        
        return path
    }
}

private struct StarDetailing : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var g = starDetailingLayoutConfig.layout(in: rect)

        path.move(g[1, 0])
        
        for segment in 1...g.yCount {
            let point = g[segment.isEven ? 1 : 0, segment]
            path.line(point)
            if (segment.isOdd) {
                path.line(from: g.center, to: point)
            }
        }
        
        return path
    }
}

private struct BrushedOverlay : Shape {
    let numCircles = 100
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let step = 1 / numCircles.asCGFloat
        
        for index in 1...numCircles {
            path.ellipse(rect.center, rect.sizeScaled(step * index.asCGFloat + 0.02.random()), anchor: .center)
        }
        
        return path
    }
}

struct CaptainAmericaShield_Previews: PreviewProvider {
    struct CaptainAmericaShield_Harness : View {
        var body : some View {
            CaptainAmericaShield()
        }
    }
    
    static var previews: some View {
        CaptainAmericaShield_Harness()
            .showLayoutGuides(true)
            .previewDevice(.iPhone_12_Pro_Max)
            .padding()
            .previewSizeThatFits()
    }
}
