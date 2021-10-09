
import SwiftUI
import PureSwiftUI

private let buttonBlue = Color(red: 42/255, green: 99/255, blue: 228/255)

private typealias TitleAndSymbol = (title: String, symbol: SFSymbolName)

private let buttonTitlesAndSymbols: [[TitleAndSymbol]] = [
    [("Favorite", .star), ("Tag", .tag), ("Share", .square_and_arrow_up)],
    [("Comment", .text_bubble), ("Delete", .trash)]
]

struct MyFitnessPalButton: View {
    fileprivate let titleAndSymbol : TitleAndSymbol
    
    var body: some View {
        Circle()
            .fillColor(.white)
            .overlay(SFSymbol(titleAndSymbol.symbol))
            .overlay(CaptionText(titleAndSymbol.title.uppercased(), .white, .semibold).fixedSize().yOffset(40))
            .frame(50)
    }
}

private let defaultAnimation = Animation.easeOut(duration: 0.2)
private let hideAnimation = defaultAnimation
private let showAnimation = Animation.spring(response: 0.3, dampingFraction: 0.6)

struct MyFitnessPalAddAnimation: View {
    @State private var homeLocation : CGPoint = CGPoint.zero
    @State private var showingButtons = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .opacityIfNot(self.showingButtons, 0)
                .animation(defaultAnimation)
            VStack(spacing: 60) {
                Spacer()
                ForEach(0..<buttonTitlesAndSymbols.count) { rowIndex in
                    HStack(spacing: 60) {
                        ForEach(0..<buttonTitlesAndSymbols[rowIndex].count) { colIndex in
                            MyFitnessPalButton(titleAndSymbol: buttonTitlesAndSymbols[rowIndex][colIndex])
                                .offsetToPositionIfNot(self.showingButtons, self.homeLocation)
                                .opacityIfNot(self.showingButtons, 0)
                        }
                    }
                }
                Circle()
                    .fill(buttonBlue)
                    .overlay(SFSymbol(.plus).foregroundColor(.white).rotateIf(self.showingButtons, -45.degrees))
                    .frame(48)
                    .geometryReader { (geo: GeometryProxy) in
                        self.homeLocation = geo.globalCenter
                    }
                    .onTapGesture {
                        withAnimation(self.showingButtons ? hideAnimation : showAnimation) {
                            self.showingButtons.toggle()
                        }
                    }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MyFitnessPalAddAnimation_Previews: PreviewProvider {
    static var previews: some View {
        MyFitnessPalAddAnimation()
    }
}

