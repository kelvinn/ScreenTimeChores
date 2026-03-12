import SwiftUI
import FamilyControls

/// Main content view with tab-based navigation
struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            // Setup Tab
            SetupView()
                .tabItem {
                    Label("Setup", systemImage: "gearshape")
                }

            // Rewards Tab
            RewardsView()
                .tabItem {
                    Label("Rewards", systemImage: "star")
                }

            // Session Tab
            SessionView()
                .tabItem {
                    Label("Session", systemImage: "play.circle")
                }

            // Status Tab
            StatusView()
                .tabItem {
                    Label("Status", systemImage: "info.circle")
                }
        }
        .tint(.blue)
        .onAppear {
            appState.recoverState()
        }
    }
}

