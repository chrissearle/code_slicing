import SwiftUI
import PureSwiftUI

private let tipRatio = 0.365
private let steps : [CGFloat] = [0, tipRatio, 0.5, 1-tipRatio, 1]
private let iconLayoutConfig = LayoutGuideConfig.grid(columns: steps, rows: steps)

private let addedColor = Color(hue: 0.58, saturation: 0.5, brightness: 1)

struct DisneyPlusAddIcon: View {
    @State private var added = false
    
    var body: some View {
        let color = added ? addedColor : Color.white
        GeometryReader { (geo: GeometryProxy) in
            let strokeSize = geo.widthScaled(0.075)
            AddIcon(added: added)
                .stroke(color, style: .init(lineWidth: strokeSize, lineCap: .round))
                .clipCircleWithStroke(Color.white, lineWidth: strokeSize)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        added.toggle()
                    }
                }
                .layoutGuide(iconLayoutConfig)
        }
    }
}

private struct AddIcon: Shape {
    
    var added: Bool
    var animatableData: Double
    
    init(added: Bool) {
        self.added = added
        self.animatableData = added ? 1 : 0
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
                
        var gh = iconLayoutConfig.layout(in: rect)
            .scaled(.width(0.6), factor: animatableData)
        
        if (added) {
            gh = gh
                .rotated(-135.degrees, factor: animatableData)
        } else {
            gh = gh
                .rotated(225.degrees, factor: animatableData)
        }
         
        gh = gh.offset(rect.sizeScaled(-0.11, 0.08).asCGPoint, factor: animatableData)

        path.line(from: gh[1, 2], to: gh[3, 2])
        
        var gv = iconLayoutConfig.layout(in: rect)
            .scaled(.height(1.3), factor: animatableData)
            .rotated(218.degrees, factor: animatableData)
            .xOffset(rect.widthScaled(0.06), factor: animatableData)

        path.line(from: gv[2, 1], to: gv[2, 3])

        return path
    }
}


struct DisneyPlusAddIcon_Harness: View {
    var body: some View {
        VStack(spacing: 50) {
            ForEach([200, 100, 50], id: \.self) { (size: CGFloat) in
                DisneyPlusAddIcon()
                    .frame(size)
            }
        }
        .greedyFrame()
        .background(Color(white: 0.1))
        .ignoresSafeArea()
        .showLayoutGuides(false)

    }
}

struct DisneyPlusAddIcon_Previews: PreviewProvider {
    static var previews: some View {
        DisneyPlusAddIcon_Harness()
    }
}
