import SwiftUI
import PureSwiftUI

struct InnerShadowsOnText: View {
    var body: some View {
        Text("ADAM\nIS")
            .font(.system(size: 200, weight: .black))
            .innerShadow(LinearGradient([.red, .orange], to: .bottomTrailing), radius: 10)
            .fixedSize()
            .multilineTextAlignment(.center)
        Text("HULK")
            .font(.system(size: 200, weight: .black))
            .innerShadow(Image("hulk-eyes").resizedToFit(), opacity: 1)
            .fixedSize()
    }
}

private extension Text {
    func innerShadow<V: View>(_ background: V, radius: CGFloat = 5, opacity: Double = 0.7) -> some View {
        self
            .overlay(background.mask(self))
            .foregroundColor(.clear)
            .overlay(
                ZStack {
                    self.foregroundColor(Color(white: 1 - opacity))
                    self.foregroundColor(.white).blur(radius).offset(5, 5)
                }
                .mask(self)
                .blendMode(.multiply)
            )
    }
}

struct InnerShadowsOnText_Harness : View {
    var body: some View {
        VStack {
            InnerShadowsOnText()
        }
    }
}

struct InnerShadowsOnText_Previews: PreviewProvider {
    static var previews: some View {
        InnerShadowsOnText_Harness()
            .hPadding(25)
            .background(Color(white: 0.1).ignoresSafeArea())
            .previewSizeThatFits()
    }
}
