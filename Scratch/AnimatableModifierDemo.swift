import SwiftUI
import PureSwiftUI

struct AnimatableModifierDemo: View {
    @State private var toggle = false
    
    var body: some View {
        ZStack {
            DemoCircle()
            ArrowSymbol()
           //     .rotateIf(toggle, -180.degrees)
            //     .xOffset(100)
            //    .rotateIf(toggle, 180.degrees)
                .offsetAndRotate(offset: toggle ? 100 : 0, angle: toggle ? 270.degrees : 90.degrees)
        }
        .contentShape(Circle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 2)) {
                toggle.toggle()
            }
        }
    }
}

private struct OffsetAndRotateModifier: AnimatableModifier {
    var offset: CGFloat
    var angle: Angle
    
    var animatableData: AnimatablePair<CGFloat, Double> {
        get {
            AnimatablePair(offset, angle.degrees)
        }
        set {
            offset = newValue.first
            angle = newValue.second.degrees
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(.point(offset, angle))
            
    }
}

private extension View {
    func offsetAndRotate(offset: CGFloat, angle: Angle) -> some View {
        modifier(OffsetAndRotateModifier(offset: offset, angle: angle))
    }
}

private struct DemoCircle: View {
    var body: some View {
        Circle()
            .stroke(Color.white, lineWidth: 4)
            .frame(100)
    }
}

private struct ArrowSymbol: View {
    var body: some View {
        SFSymbol(.arrow_up)
            .resizedToFit(50)
            .foregroundColor(.white)
    }
}

struct AnimatableModifierDemo_Harness: View {
    var body: some View {
        AnimatableModifierDemo()
            .greedyFrame()
            .background(Color(white: 0.1))
            .ignoresSafeArea()
    }
}

struct AnimatableModifierDemo_Previews: PreviewProvider {
    static var previews: some View {
        AnimatableModifierDemo_Harness()
            .previewDevice(.iPhone_11_Pro_Max)
    }
}
