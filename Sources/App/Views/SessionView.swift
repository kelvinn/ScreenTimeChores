import SwiftUI

/// Session view for starting and managing active sessions
struct SessionView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                // Session Status Section
                Section {
                    SessionStatusCard(
                        isActive: appState.activeSession.isActive,
                        remainingMinutes: appState.activeSession.remainingMinutes,
                        startedAt: appState.activeSession.startedAt,
                        shieldApplied: appState.enforcementState.shieldApplied
                    )
                }

                // Session Control Section
                Section {
                    if appState.activeSession.isActive {
                        // Active session - show stop button
                        Button(role: .destructive) {
                            appState.stopSession()
                        } label: {
                            HStack {
                                Image(systemName: "stop.circle.fill")
                                Text("End Session")
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        // No active session - show start button
                        Button {
                            appState.startSession()
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Start Reward Time")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .disabled(!canStartSession)
                    }
                }

                // Requirements Section
                if !canStartSession && !appState.activeSession.isActive {
                    Section {
                        if appState.authorizationStatus != .approved {
                            RequirementRow(
                                isMet: false,
                                text: "Screen Time authorization required"
                            )
                        }
                        if appState.selectedTargets.isEmpty {
                            RequirementRow(
                                isMet: false,
                                text: "Select apps to restrict"
                            )
                        }
                        if appState.timeBank.remainingSeconds <= 0 {
                            RequirementRow(
                                isMet: false,
                                text: "Earn or add time to balance"
                            )
                        }
                    } header: {
                        Text("Requirements to Start")
                    }
                }

                // Time Bank Preview
                Section {
                    HStack {
                        Text("Available Balance")
                        Spacer()
                        Text("\(appState.timeBank.remainingMinutes) min")
                            .foregroundColor(.secondary)
                    }

                    if !appState.selectedTargets.isEmpty {
                        HStack {
                            Text("Apps Blocked")
                            Spacer()
                            Text("\(appState.selectedTargets.totalCount)")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Current Status")
                }
            }
            .navigationTitle("Session")
        }
    }

    private var canStartSession: Bool {
        appState.authorizationStatus == .approved &&
        !appState.selectedTargets.isEmpty &&
        appState.timeBank.remainingSeconds > 0
    }
}

/// Session status card
struct SessionStatusCard: View {
    let isActive: Bool
    let remainingMinutes: Int
    let startedAt: Date?
    let shieldApplied: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Status indicator
            HStack {
                Circle()
                    .fill(isActive ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
                Text(isActive ? "Session Active" : "No Active Session")
                    .font(.headline)
                Spacer()
            }

            if isActive {
                // Timer display
                VStack(spacing: 4) {
                    Text("\(remainingMinutes)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(remainingMinutes > 5 ? .primary : .red)
                    Text("minutes remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Start time
                if let startedAt = startedAt {
                    Text("Started at \(startedAt, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Shield status
                HStack {
                    Image(systemName: shieldApplied ? "lock.open" : "lock")
                        .foregroundColor(shieldApplied ? .orange : .green)
                    Text(shieldApplied ? "Apps Unlocked" : "Apps Locked")
                        .font(.subheadline)
                }
            } else {
                // Not active state
                VStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Start a session to unlock your apps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// Requirement row
struct RequirementRow: View {
    let isMet: Bool
    let text: String

    var body: some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isMet ? .green : .red)
            Text(text)
                .foregroundColor(.primary)
        }
    }
}

