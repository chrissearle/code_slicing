//
//  AnimatedTrainWheelDemo.swift
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
//  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Adam Fordyce on 21/11/2020.
//  Copyright © 2020 Adam Fordyce. All rights reserved.
//

import SwiftUI
import PureSwiftUI

private let wheelOrigin = UnitPoint(0.75, 0.5)
private let connectingRodLayoutConfig = LayoutGuideConfig.grid(columns: 1, rows: 1)
private let wheelSpokesLayoutConfig = LayoutGuideConfig.polar(rings: [0.1, 0.8], segments: 16, origin: wheelOrigin)
private let wheelCrankLayoutConfig = LayoutGuideConfig.polar(rings: [0.4], segments: 1, origin: wheelOrigin)
private let wheelCounterweightLayoutConfig = LayoutGuideConfig.polar(rings: [0.85], segments: 24, origin: wheelOrigin)

struct AnimatedTrainWheelDemo: View {
    @State private var animating = false
    var body: some View {

        let wheelColor = Color.gray

        GeometryReader { (geo: GeometryProxy) in
            ZStack {
               ZStack {
                   StrokedShape(WheelSpokesShape(factor: animating ? 1 : 0), color: wheelColor, lineWidth: 6)
               }
               ZStack {
                FilledShape(WheelCrankShape(factor: animating ? 1 : 0, diameter: geo.heightScaled(0.18)), color: wheelColor)
                   FilledShape(WheelCounterweightShape(factor: animating ? 1 : 0), color: wheelColor)
                   FilledShape(WheelRimAndHubShape(radii: [0.18, 0.8, 1]), color: wheelColor)
                   FilledShape(WheelRimAndHubShape(radii: [0.15, 0.96, 1]), color: Color.white, shadow: false)
               }
               ZStack {
                FilledShape(ConnectingRodShape(factor: animating ? 1 : 0, diameter: geo.heightScaled(0.1)), color: wheelColor)
                   FilledShape(ConnectingRodShape(factor: animating ? 1 : 0, diameter: geo.heightScaled(0.06)), color: Color.white, shadow: false)
                   FilledShape(ConnectingRodCoverShape(factor: animating ? 1 : 0, diameter: geo.heightScaled(0.14)), color: wheelColor)
               }
               ZStack {
                   FilledShape(WheelConnectingCircleShape(factor: animating ? 1 : 0, diameter: geo.heightScaled(0.14)), color: wheelColor)
                   FilledShape(WheelConnectingCircleShape(factor: animating ? 1 : 0, diameter: geo.heightScaled(0.1)), color: Color.white, shadow: false)
                   StrokedShape(WheelConnectingCircleShape(factor: animating ? 1 : 0, diameter: geo.heightScaled(0.05)), color: wheelColor, lineWidth: geo.heightScaled(0.005), shadow: false)
               }
           }
        }
        .frame(300, 200)
        .padding(10)
        .hPadding(30)
        .clipped()
        .cutoutRoundedRectangle(20)
        .onAppear {
            withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                self.animating = true
            }
        }
    }
}

private struct StrokedShape<T: Shape>: View {
    let shape: T
    let color: Color
    let lineWidth: CGFloat
    let shadow: Bool
    
    init(_ shape: T, color: Color, lineWidth: CGFloat, shadow: Bool = true) {
        self.shape = shape
        self.color = color
        self.lineWidth = lineWidth
        self.shadow = shadow
    }
    
    var body: some View {
        shape
        .stroke(color, lineWidth: lineWidth)
        .backgroundIf(shadow, shape
            .stroke(Color(white: 0.6), lineWidth: lineWidth).blur(1).blendMode(.multiply))
    }
}

private struct FilledShape<T: Shape>: View {
    let shape: T
    let color: Color
    let shadow: Bool
    
    init(_ shape: T, color: Color, shadow: Bool = true) {
        self.shape = shape
        self.color = color
        self.shadow = shadow
    }
    
    var body: some View {
        shape
        .fill(color, style: .init(eoFill: true, antialiased: true))
        .backgroundIf(shadow, shape
            .fill(Color(white: 0.6), style: .init(eoFill: true, antialiased: true)).blur(2).blendMode(.multiply))
    }
}

private protocol AnimatableShapeWithFactor: Shape {
    var factor: CGFloat {get set}
}

private extension AnimatableShapeWithFactor {
    var animatableData: CGFloat {
        get {
            factor
        }
        set {
            factor = newValue
        }
    }
}

private struct WheelSpokesShape: AnimatableShapeWithFactor {
    var factor: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let polar = wheelSpokesLayoutConfig.layout(in: rect)
            .rotated(360.degrees, factor: factor)
        for segment in 0..<polar.yCount {
            path.line(from: polar[0, segment], to: polar[1, segment])
        }
        return path
    }
}

private struct WheelCounterweightShape: AnimatableShapeWithFactor {
    var factor: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let polar = wheelCounterweightLayoutConfig.layout(in: rect)
            .rotated(360.degrees, factor: factor)
        path.move(polar[1, 9])
        path.arc(polar.center, radius: polar.radiusTo(1, 0), startAngle: polar.angleTo(1, 9), endAngle: polar.angleTo(1, 15))
        path.line(polar[1, 9])
        for segment in 0..<polar.yCount {
            path.line(from: polar[0, segment], to: polar[1, segment])
        }
        return path
    }
}

private struct WheelRimAndHubShape: Shape {
    let radii: [CGFloat]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let polar = LayoutGuide.polar(rect, rings: radii, segments: 1, origin: UnitPoint(0.75, 0.5))
      
        path.ellipse(polar.center, .square(polar.radiusTo(2, 0) * 2), anchor: .center)
        path.ellipse(polar.center, .square(polar.radiusTo(1, 0) * 2), anchor: .center)
        path.ellipse(polar.center, .square(polar.radiusTo(0, 0) * 2), anchor: .center)
        
        return path
    }
}

private struct WheelCrankShape: AnimatableShapeWithFactor {
    var factor: CGFloat
    var diameter: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let polar = wheelCrankLayoutConfig.layout(in: rect)
            .rotated(360.degrees, factor: factor)
        let attachmentRect = CGRect(polar.center.yOffset(diameter / -2), .size(polar.radiusTo(0, 0), diameter))
        let grid = LayoutGuide.grid(attachmentRect, columns: 8, rows: [0, 0.2, 0.8, 1])
            .rotated(from: -90.degrees, to: 270.degrees, anchor: .leading, factor: factor)

        path.move(grid.topLeading)
        path.line(grid[grid.xCount, 1])
        path.line(grid[grid.xCount, 2])
        path.line(grid.bottomLeading)
        path.closeSubpath()
        
        return path
    }
}

private struct WheelConnectingCircleShape: AnimatableShapeWithFactor {
    var factor: CGFloat
    var diameter: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let polar = wheelCrankLayoutConfig.layout(in: rect)
            .rotated(360.degrees, factor: factor)
        path.ellipse(polar[0, 0], .square(diameter), anchor: .center)
        
        return path
    }
}

private struct ConnectingRodShape: AnimatableShapeWithFactor {
    var factor: CGFloat
    var diameter: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let polar = wheelCrankLayoutConfig.layout(in: rect)
            .rotated(360.degrees, factor: factor)
        
        let rodOrigin = rect.leading.xOffset(rect.widthScaled(-0.25))
        let rodLength = polar.radiusTo(0, 0, from: rodOrigin)
        let rodAngle = polar.angleTo(0, 0, from: rodOrigin)
        let rodRect = CGRect(rodOrigin.yOffset(-diameter / 2), .size(rodLength, diameter))
        
        let grid = connectingRodLayoutConfig.layout(in: rodRect)
            .rotated(-90.degrees + rodAngle, anchor: .leading)
        
        drawLayoutBorder(grid, &path)
        
        return path
    }
}

private struct ConnectingRodCoverShape: AnimatableShapeWithFactor {
    var factor: CGFloat
    var diameter: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let polar = wheelCrankLayoutConfig.layout(in: rect)
            .rotated(360.degrees, factor: factor)
        
        let rodOrigin = rect.leading.xOffset(rect.widthScaled(-0.25))
        let rodAngle = polar.angleTo(0, 0, from: rodOrigin)
        let rodCoverRect = CGRect(rodOrigin.yOffset(-diameter / 2), .size(rect.widthScaled(0.4), diameter))
        
        let grid = connectingRodLayoutConfig.layout(in: rodCoverRect)
            .rotated(-90.degrees + rodAngle, anchor: .leading)
        
        drawLayoutBorder(grid, &path)
        
        return path
    }
}

private func drawLayoutBorder(_ layout: LayoutGuide, _ path: inout Path) {
    
    path.move(layout.topLeading)
    path.line(layout.topTrailing)
    path.line(layout.bottomTrailing)
    path.line(layout.bottomLeading)
    path.closeSubpath()
    
}

struct AnimatedTrainWheelDemo_Previews: PreviewProvider {
    struct AnimatedTrainWheelDemo_Harness: View {
        
        var body: some View {
            AnimatedTrainWheelDemo()
        }
    }
    
    static var previews: some View {
        AnimatedTrainWheelDemo_Harness()
            .previewSizeThatFits()
            .padding(50)
    }
}

