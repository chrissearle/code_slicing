import SwiftUI
import PureSwiftUI

private func createColor(_ red: Double, _ green: Double, _ blue: Double) -> Color {
    Color(red: red/255, green: green/255, blue: blue/255)
}

private let gradientStart = createColor(82, 215, 157)
private let gradientEnd = createColor(51, 167, 175)

private let gradient = LinearGradient([gradientStart, gradientEnd], to: .bottom)
private let maskGradient = LinearGradient([.black], to: .bottom)

private let maxSize: CGFloat = 200
private let minSize: CGFloat = 40

private let inhaleTime: Double = 3
private let exhaleTime: Double = 4
private let pauseTime: Double = 0.5

private let ghostMaxSize: CGFloat = maxSize * 0.99
private let ghostMinSize: CGFloat = maxSize * 0.94



struct BreatheAnimation: View {
    @State private var size = minSize
    @State private var inhaling = false
    
    @State private var ghostSize = ghostMaxSize
    @State private var ghostBlur: Double = 0
    @State private var ghostOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Petals(size: ghostSize, inhaling: inhaling)
                .blur(ghostBlur)
                .opacity(ghostOpacity)
                .drawingGroup()

            Petals(size: size, inhaling: inhaling, isMask: true)
            Petals(size: size, inhaling: inhaling)
        }
        .rotateIf(inhaling, 60.degrees)
        .rotateIfNot(inhaling, -30.degrees)
        .onTapGesture {
            performAnimations()
        }
    }

    private func performAnimations() {
        withAnimation(.easeInOut(duration: inhaleTime)) {
            inhaling = true
            size = maxSize
        }
        after(inhaleTime + pauseTime) {
            ghostSize = ghostMaxSize
            ghostBlur = 0
            ghostOpacity = 0.8
            
            after(exhaleTime * 0.2) {
                withAnimation(.easeOut(duration: exhaleTime * 0.6)) {
                    ghostOpacity = 0
                    ghostBlur = 10
                }
            }
            
            withAnimation(.easeInOut(duration: exhaleTime)) {
                inhaling = false
                size = minSize
                ghostSize = ghostMinSize
            }
        }
    }
}

struct Petals : View {
    
    let size: CGFloat
    let inhaling: Bool
    var isMask = false
    
    var body: some View {
        
        let petalsGradient = isMask ? maskGradient : gradient
        
        ZStack {
            ForEach(0..<6) { index in
                petalsGradient
                    .mask(
                        Circle()
                            .frame(size)
                            .xOffsetIf(inhaling, size * 0.5)
                            .rotate(60.degrees * index)
                    )
                    .blendMode(isMask ? .normal : .screen)
            }
        }
        .frameIf(inhaling, size * 2)
        .frameIfNot(inhaling, size)
    }
}

struct BreatheAnimation_Harness : View {
    var body: some View {
        VStack {
            BreatheAnimation()
                .greedyFrame()
                .backgroundColor(Color(white: 0.1))
                .ignoresSafeArea()
        }
    }
}

struct BreatheAnimation_Previews: PreviewProvider {
    static var previews: some View {
        BreatheAnimation_Harness()
            .previewDevice(.iPhone_11_Pro_Max)
    }
}
