import SwiftUI

/// Status view for diagnostics and debugging
struct StatusView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                // Authorization Status
                Section {
                    StatusRow(
                        title: "Authorization",
                        value: appState.authorizationStatus.rawValue,
                        isGood: appState.authorizationStatus == .approved
                    )

                    StatusRow(
                        title: "Targets Selected",
                        value: "\(appState.selectedTargets.totalCount)",
                        isGood: appState.selectedTargets.totalCount > 0
                    )

                    StatusRow(
                        title: "Shield Active",
                        value: appState.enforcementState.shieldApplied ? "Yes" : "No",
                        isGood: appState.enforcementState.shieldApplied != appState.activeSession.isActive
                    )
                } header: {
                    Text("Current State")
                }

                // Session Status
                Section {
                    StatusRow(
                        title: "Session Active",
                        value: appState.activeSession.isActive ? "Yes" : "No",
                        isGood: true
                    )

                    if appState.activeSession.isActive {
                        StatusRow(
                            title: "Time Remaining",
                            value: "\(appState.activeSession.remainingMinutes) min",
                            isGood: appState.activeSession.remainingMinutes > 0
                        )

                        if let startedAt = appState.activeSession.startedAt {
                            StatusRow(
                                title: "Started At",
                                value: formatDate(startedAt),
                                isGood: true
                            )
                        }
                    }
                } header: {
                    Text("Session")
                }

                // Time Bank
                Section {
                    StatusRow(
                        title: "Balance",
                        value: "\(appState.timeBank.remainingMinutes) min",
                        isGood: appState.timeBank.remainingSeconds > 0
                    )

                    StatusRow(
                        title: "Total Earned",
                        value: "\(appState.timeBank.totalBankedMinutes) min",
                        isGood: true
                    )

                    StatusRow(
                        title: "Last Updated",
                        value: formatDate(appState.timeBank.lastUpdatedAt),
                        isGood: true
                    )
                } header: {
                    Text("Time Bank")
                }

                // Enforcement History
                Section {
                    if let lastApplied = appState.enforcementState.lastShieldAppliedAt {
                        StatusRow(
                            title: "Last Shield Applied",
                            value: formatDate(lastApplied),
                            isGood: true
                        )
                    }

                    if let lastRemoved = appState.enforcementState.lastShieldRemovedAt {
                        StatusRow(
                            title: "Last Shield Removed",
                            value: formatDate(lastRemoved),
                            isGood: true
                        )
                    }

                    if let lastEvent = appState.enforcementState.lastMonitorEventAt {
                        StatusRow(
                            title: "Last Monitor Event",
                            value: formatDate(lastEvent),
                            isGood: true
                        )
                    }

                    if let error = appState.enforcementState.lastError {
                        StatusRow(
                            title: "Last Error",
                            value: error,
                            isGood: false
                        )
                    }
                } header: {
                    Text("Enforcement History")
                }

                // Warnings Section
                Section {
                    WarningRow()
                } header: {
                    Text("Platform Limitations")
                }
            }
            .navigationTitle("Status")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

/// Status row
struct StatusRow: View {
    let title: String
    let value: String
    let isGood: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(isGood ? .primary : .red)
                .fontWeight(isGood ? .regular : .medium)
        }
    }
}

/// Warning about individual authorization limitations
struct WarningRow: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Individual Authorization Limitations")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This app uses individual authorization, not child account parental controls.")
                        .font(.caption)

                    Text("Limitations:")
                        .font(.caption.bold())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• User can disable restrictions in Settings")
                        Text("• No cross-device management")
                        Text("• Timing may not be exact")
                        Text("• Less tamper resistance than child accounts")
                    }
                    .font(.caption)
                }
                .padding(.top, 4)
            }
        }
    }
}

