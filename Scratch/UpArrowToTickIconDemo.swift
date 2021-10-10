import SwiftUI
import PureSwiftUI

private let iconLayoutConfig = LayoutGuideConfig.grid(columns: 10, rows: 10)

struct UpArrowToTickIconDemo: View {
    @State private var cp0 = CGPoint(0.85, 0)
    @State private var cp1 = CGPoint(0.15, 1)

    @State private var success = false
    
    var body: some View {
        let customTimingCurve = CustomTimingCurve(cp0: $cp0, cp1: $cp1)
        
        return VStack {
            UpArrowToTickIcon(success: success)
                .stroke(Color.white, style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .frame(200)
                .contentShape(Rectangle())
                .onTapGesture {
                    //withAnimation(.timingCurve(0.85, 0, 0.15, 1, duration: 0.45)) {
                    withAnimation(customTimingCurve.generate(duration: 0.45)) {
                        self.success.toggle()
                    }
                }
                customTimingCurve.asView(200)
                    .padding(.top, 50)
        }
        .greedyFrame()
        .background(Color(white: 0.1))
        .edgesIgnoringSafeArea(.all)
    }
}

private struct UpArrowToTickIcon : Shape {
    var animatableData: Double = 1
    
    init(success: Bool) {
        self.animatableData = success ? 1 : 0
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        
        let g = iconLayoutConfig.layout(in: rect)
            .rotated(225.degrees, factor: animatableData)
            .xOffset(rect.widthScaled(0.07), factor: animatableData)
        
        
        path.line(from: g[5, 8], to: g[5, 2])
        path.move(g[3, 4].to(g[5, 4], animatableData))
        path.line(g[5, 2])
        path.line(g[7, 4].to(g[7, 2], animatableData))

        return path
    }
}


struct UpArrowToTickIconDemo_Previews: PreviewProvider {
    struct UpArrowToTickIconDemo_Harness: View {
        var body: some View {
            UpArrowToTickIconDemo()
        }
    }
    
    static var previews: some View {
        UpArrowToTickIconDemo_Harness()
    }
}

