import SwiftUI
import FamilyControls

/// Main content view with tab-based navigation
struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            // Dashboard Tab (Home)
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "shield.checkered")
                }

            // Setup Tab
            SetupView()
                .tabItem {
                    Label("Setup", systemImage: "gearshape")
                }

            // Tasks Tab
            ChoresView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
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

