import SwiftUI

@main
struct ScratchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                List {
                    Group {
                        NavigationLink("MyFitnessPal") {
                            MyFitnessPalAddAnimation()
                        }
                        NavigationLink("Grid Layout") {
                            GridLayoutArrowDemo()
                        }
                        NavigationLink("Polar Layout") {
                            PolarLayoutStarDemo()
                        }
                        NavigationLink("Heart") {
                            HeartDemo()
                        }
                        NavigationLink("Animated Arrow") {
                            AnimatedArrowDemo()
                        }
                        NavigationLink("Animated Heart") {
                            AnimatedHeartDemo()
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
                        NavigationLink("UpArrowToTick") {
                            UpArrowToTickIconDemo()
                        }
                    }
                    Group {
                        
                        NavigationLink("Disney+ Add") {
                            DisneyPlusAddIcon_Harness()
                        }
                        NavigationLink("Safari Icon") {
                            SafariIcon_Harness()
                        }
                        NavigationLink("Transforming Layout Guides") {
                            TransformingLayoutGuides_Harness()
                        }
                        NavigationLink("Transforming Animated Heart") {
                            TransformingAnimatedHeartDemo()
                        }
                        NavigationLink("Animatable Modifier Demo") {
                            AnimatableModifierDemo_Harness()
                        }
                        NavigationLink("Breathe") {
                            BreatheAnimation_Harness()
                        }
                        NavigationLink("Chrome") {
                            ChromeIcon_Harness()
                        }
                        NavigationLink("Connected Wheels") {
                            ConnectedWheelsDemo()
                        }
                        NavigationLink("Animated Train Wheel") {
                            AnimatedTrainWheelDemo()
                        }
                        NavigationLink("Settings") {
                            SettingsIcon_Harness()
                        }
                    }
                    Group {
                        NavigationLink("Sticky Toggle") {
                            StickyToggle_Harness()
                        }
                        NavigationLink("Shazam") {
                            ShazamOpeningAnimation_Harness()
                        }
                        NavigationLink("Photos") {
                            PhotosIcon_Harness()
                        }
                        NavigationLink("Inner Shadow On Text") {
                            InnerShadowsOnText_Harness()
                        }
                    }
                }
                Spacer()
            }
        }
    }
}
