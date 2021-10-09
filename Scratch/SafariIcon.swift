import SwiftUI
import PureSwiftUI

private func createColor(_ red: Double, _ green: Double, _ blue: Double) -> Color {
    Color(red: red/255, green: green/255, blue: blue/255)
}

private let gradientStart = createColor(36, 199, 249)
private let gradientEnd = createColor(37, 109, 236)
private let pointerColor = createColor(251, 61, 41)

private let gradLayoutConfig = LayoutGuideConfig.polar(rings: [0, 0.83, 0.91, 1], segments: 72)

private let halfTriangleWidth = 0.065
private let halfTriangleTipWidth = 0.005

private let pointerLayoutConfig = LayoutGuideConfig.grid(columns: [0, 0.5 - halfTriangleWidth, 0.5 - halfTriangleTipWidth, 0.5 + halfTriangleTipWidth, 0.5 + halfTriangleWidth, 1], rows: 2)

struct SafariIcon: View {
    @State private var animating = false
    
    var body: some View {
        GeometryReader { (geo: GeometryProxy) in
            ZStack {
                RoundedRectangle(geo.widthScaled(0.2))
                    .fill(Color.white)
                Circle()
                    .fill(LinearGradient([gradientStart, gradientEnd], to: .bottom))
                    .frame(geo.widthScaled(0.87))
                Graduations()
                    .stroke(Color.white, lineWidth: geo.widthScaled(0.01))
                    .frame(geo.widthScaled(0.8))
                Group {
                    Pointer(isShadow: true)
                        .blur(geo.widthScaled(0.02))
                        .drawingGroup() // needed to fix blendMode
                        .blendMode(.multiply)
                    
                   Pointer()
                }
                 .frame(geo.widthScaled(0.8))
                 //.rotate(50.degrees)
                 .rotateIf(animating, 360.degrees)
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: false)) {
                    animating = true
                }
            }
        }
    }
}

private struct Pointer : View {
    var isShadow = false
    
    var body: some View {
        ZStack {
            PTriangle()
                .fill(isShadow ? Color.gray : pointerColor)
            PTriangle()
                .fill(isShadow ? Color.gray : Color.white)
                .rotate(180.degrees)
        }
    }
}

private struct PTriangle : Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var g = pointerLayoutConfig.layout(in: rect)
        
        path.move(g[1, 1])
        path.line(g[2, 0])
        path.line(g[3, 0])
        path.line(g[4, 01])

        return path
    }
}


private struct Graduations : Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var g = gradLayoutConfig.layout(in: rect)
        
        for segment in 0..<g.yCount {
            path.line(from: g[3, segment], to: g[segment.isOdd ? 2 : 1, segment])
        }
        
        return path
    }
}

struct SafariIcon_Harness: View {
    var body: some View {

        VStack(spacing: 50) {
            ForEach([200, 100, 50], id: \.self) { (size: CGFloat) in
                SafariIcon()
                    .frame(size)
            }
        }
        .greedyFrame()
        .background(Color(white: 0.1))
        .ignoresSafeArea()
        .showLayoutGuides(false)
    }
}

struct SafariIcon_Previews: PreviewProvider {


    static var previews: some View {
        SafariIcon_Harness()
    }
}

