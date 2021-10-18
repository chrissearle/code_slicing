import SwiftUI
import PureSwiftUI

private let startColor = Color.rgb8(228, 229, 231)
private let endColor = Color.rgb8(139, 143, 150)

private let gradient = LinearGradient([startColor, endColor], to: .bottom)

private let numberOfTeeth = 54
private let segmentsPerTooth = 20
private let numberOfSegments = numberOfTeeth * segmentsPerTooth

private let teethLayoutConfig = LayoutGuideConfig.polar(rings: [0.885, 1], segments: numberOfSegments)

private let halfSpokeWidth: CGFloat = 0.025
private let defaultAngle = -30.5.degrees
private let spokePolarConfig = LayoutGuideConfig.polar(rings: [0.78], segments: 60)
private let spokeGridConfig = LayoutGuideConfig.grid( columns: [0.5 - halfSpokeWidth, 0.5 + halfSpokeWidth], rows: [0.1, 0.25, 0.46])

struct SettingsIcon: View {
    @State private var animating = false
    
    var body: some View {
        let debug = false
        ZStack {
            Color(white: 0.183)
                .clipCircle()
                .opacityIf(debug, 0)

            Shroud()
                .iconStyle(debug: debug)

            Cog(inner: false, scale: 0.3, debug: debug)
                .rotateIfNot(debug, -defaultAngle)
                .rotateIf(!debug && animating, -720.degrees)
                .iconStyle(debug: debug)

            
            Cog(inner: true, scale: 0.53, debug: debug)
                .rotateIfNot(debug, defaultAngle)
                .rotateIf(!debug && animating, -360.degrees)
                .iconStyle(debug: debug)
            
            let primaryCogScale: CGFloat = 0.8
            Cog(scale: primaryCogScale, debug: debug)
                .rotateIfNot(debug, defaultAngle)
                .rotateIf(!debug && animating, 360.degrees)
                .iconStyle(debug: debug)
                // .layoutGuide(teethLayoutConfig.scaled(primaryCogScale), color: .green)
                .layoutGuide(spokePolarConfig.scaled(primaryCogScale), color: .blue, lineWidth: 1)
                .layoutGuide(spokeGridConfig.scaled(primaryCogScale), color: .red, lineWidth: 1)
                .layoutGuide(spokeGridConfig.scaled(primaryCogScale).rotated(120.degrees), color: .red, lineWidth: 1)
        }
        .shadowIfNot(debug, color: Color.black, radius: 10)
        .showLayoutGuides(debug)
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                self.animating = true
            }
        }
    }
}

private extension Shape {
    @ViewBuilder func iconStyle(debug: Bool = false) -> some View {
        if debug {
            stroke(Color.white, style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round))
        } else {
            fill(gradient, style: .init(eoFill: true))
        }
    }
}

private struct Shroud : Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.roundedRect(rect, cornerRadius: rect.widthScaled(0.22))
        path.ellipse(rect.center, rect.sizeScaled(0.87), anchor: .center)
        
        return path
    }
}

private struct Cog : Shape {
    var inner = false
    
    var scale: CGFloat
   
    var debug = false
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var g = teethLayoutConfig.scaled(scale).layout(in: rect)
        
        let rotationDelta = g.angleTo(0, segmentsPerTooth)
        
        path.move(g[0,0])

        g = g
            .rotated(-g.angleTo(1, 5))
        
        for tooth in 0..<numberOfTeeth {
            let g = g
                .rotated(rotationDelta * tooth)
            path.line(g[1,4])
            path.line(g[1,6])
            path.line(g[0,10])
            path.line(g[0,20])
        }
        
        path.closeSubpath()
        
        if !inner {
            var p = spokePolarConfig.scaled(scale).layout(in: rect)
            var gr = spokeGridConfig.scaled(scale).layout(in: rect)
        
            for _ in 0..<3 {
                path.move(gr[1, 2])
                path.line(gr[1, 1])
                path.curve(p[0, 3], cp1: gr[1, 0], cp2: p[0, 2], showControlPoints: debug)
                path.arc(rect.center, radius: p.radiusTo(0, 0), startAngle: p.angleTo(0, 3), endAngle: p.angleTo(0, 17))
                
                gr = gr
                    .rotated(120.degrees)
                
                path.curve(gr[0, 1], cp1: p[0, 18], cp2: gr[0, 0], showControlPoints: debug)
                
                path.line(gr[0, 2])
                
                path.closeSubpath()
                
                p = p.rotated(120.degrees)
            }
            path.circle(rect.center, diameter: rect.widthScaled(0.04 * scale))
        } else {
            path.circle(rect.center, diameter: rect.widthScaled(0.72 * scale))
        }
 
        return path
    }
}


struct SettingsIcon_Harness : View {
    var body: some View {
        VStack {
            SettingsIcon()
                .frame(400)
                .greedyFrame()
                .background(Color(white: 0.1).ignoresSafeArea())
        }
    }
}

struct SettingsIcon_Previews: PreviewProvider {
    static var previews: some View {
        SettingsIcon_Harness()
            .previewDevice(.iPhone_12_Pro_Max)
    }
}
