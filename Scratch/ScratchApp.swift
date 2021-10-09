import SwiftUI

@main
struct ScratchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                List {
                    NavigationLink("MyFitnessPal") {
                        MyFitnessPalAddAnimation()
                    }
                    Group {
                        NavigationLink("Grid Layout") {
                            GridLayoutArrowDemo()
                        }
                        NavigationLink("Polar Layout") {
                            PolarLayoutStarDemo()
                        }
                        NavigationLink("Heart") {
                            HeartDemo()
                        }
                    }
                    Group {
                        NavigationLink("Animated Arrow") {
                            AnimatedArrowDemo()
                        }
                        NavigationLink("Animated Heart") {
                            AnimatedHeartDemo()
                        }
                    }
                    NavigationLink("Visualising Custom Timing Curves") {
                        VisualisingCustomTimingCurvesDemo()
                    }
                    NavigationLink("Captain America") {
                        CaptainAmericaShield()
                    }
                    NavigationLink("Aperture") {
                        AnimatedApertureDemo()
                    }
                    Group {
                        NavigationLink("UpArrowToTick") {
                            UpArrowToTickIconDemo()
                        }
                        NavigationLink("Disney+ Add") {
                            DisneyPlusAddIcon_Harness()
                        }
                    }
                    NavigationLink("Safari Icon") {
                        SafariIcon_Harness()
                    }
                }
                Spacer()
            }
        }
    }
}
