import SwiftUI
import FamilyControls

/// Setup view for authorization and target selection
struct SetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingFamilyPicker = false
    @State private var showingResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Authorization Section
                Section {
                    AuthorizationRow(
                        status: appState.authorizationStatus,
                        onRequestAuthorization: requestAuthorization
                    )
                } header: {
                    Text("Screen Time Authorization")
                } footer: {
                    Text("Required to use Family Controls APIs for app blocking.")
                }

                // Target Selection Section
                Section {
                    Button {
                        showingFamilyPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "app.badge.checkmark")
                                .foregroundColor(.blue)
                            Text("Select Apps to Block")
                            Spacer()
                            if appState.selectedTargets.totalCount > 0 {
                                Text("\(appState.selectedTargets.totalCount) selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(appState.authorizationStatus != .approved)

                    if appState.selectedTargets.totalCount > 0 {
                        Button(role: .destructive) {
                            showingResetAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Clear Selection")
                            }
                        }
                    }
                } header: {
                    Text("Restriction Targets")
                } footer: {
                    if appState.authorizationStatus != .approved {
                        Text("Authorize Screen Time first to select apps.")
                    }
                }

                // Quick Actions Section
                Section {
                    Button("Apply Shields Now") {
                        appState.applyShields()
                    }
                    .disabled(!appState.selectedTargets.isEmpty == false || appState.activeSession.isActive)

                    Button("Remove Shields Now") {
                        appState.removeShields()
                    }
                    .disabled(appState.activeSession.isActive)
                } header: {
                    Text("Quick Actions")
                }

                // Reset Section
                Section {
                    Button("Reset All Data", role: .destructive) {
                        showingResetAlert = true
                    }
                } header: {
                    Text("Danger Zone")
                }
            }
            .navigationTitle("Setup")
            .familyActivityPicker(
                isPresented: $showingFamilyPicker,
                selection: Binding(
                    get: { appState.selectedTargets.applications },
                    set: { newSelection in
                        var targets = appState.selectedTargets
                        targets.applications = newSelection
                        appState.updateSelectedTargets(targets)
                    }
                )
            )
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    appState.resetAll()
                }
            } message: {
                Text("This will clear all settings, time balance, and session data.")
            }
        }
    }

    private func requestAuthorization() {
        Task {
            await appState.requestAuthorization()
        }
    }
}

/// Authorization status row
struct AuthorizationRow: View {
    let status: AuthorizationStatus
    let onRequestAuthorization: () -> Void

    var body: some View {
        HStack {
            statusIcon
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Screen Time")
                    .font(.headline)
                Text(statusDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if status == .notDetermined {
                Button("Authorize") {
                    onRequestAuthorization()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .notDetermined:
            Image(systemName: "questionmark.circle")
                .foregroundColor(.orange)
        case .denied:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        case .approved:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }

    private var statusDescription: String {
        switch status {
        case .notDetermined:
            return "Not yet authorized"
        case .denied:
            return "Authorization denied"
        case .approved:
            return "Authorized"
        }
    }
}

