import SwiftUI

/// Main dashboard view combining stats, actions, chores, and activity
struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddTime = false
    @State private var showingAddTask = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection

                    // Stats Cards
                    statsSection

                    // Action Buttons
                    actionButtonsSection

                    // Chores Section
                    choresSection

                    // Completed Tasks Section
                    completedTasksSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTime) {
                AddTimeSheet { minutes in
                    appState.addTime(minutes: minutes, recordEvent: true)
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet { task in
                    appState.addTask(task)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Image(systemName: "shield.checkered")
                .font(.system(size: 28))
                .foregroundColor(.blue)

            Text("Reward Shield")
                .font(.title2.bold())

            Spacer()
        }
        .padding(.bottom, 4)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Time Shielded",
                value: formatDuration(appState.enforcementState.totalShieldedSeconds),
                icon: "lock.shield.fill",
                color: .orange
            )

            StatCard(
                title: "Time Earned",
                value: "\(appState.timeBank.totalBankedMinutes)m",
                icon: "star.fill",
                color: .green
            )

            StatCard(
                title: "Time Remaining",
                value: formatDuration(appState.timeBank.remainingSeconds),
                icon: "hourglass",
                color: .blue
            )
        }
    }

    // MARK: - Action Buttons

    private var actionButtonsSection: some View {
        EmptyView()
    }

    // MARK: - Chores Section

    private var choresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text("Available Tasks (\(appState.availableTasks.count))")
                    .font(.headline)

                Spacer()
            }

            if appState.availableTasks.isEmpty {
                Text("No tasks available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(appState.availableTasks.enumerated()), id: \.element.id) { index, task in
                        DashboardTaskRow(task: task) {
                            appState.toggleTaskCompletion(task)
                        }

                        if index < appState.availableTasks.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Completed Tasks Section

    private var completedTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Completed Tasks (\(appState.completedTasks.count))")
                    .font(.headline)

                Spacer()
            }

            if appState.completedTasks.isEmpty {
                Text("No completed tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(appState.completedTasks.enumerated()), id: \.element.id) { index, task in
                        CompletedTaskRow(task: task) {
                            appState.toggleTaskCompletion(task)
                        }

                        if index < appState.completedTasks.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Helpers

    private var canStartSession: Bool {
        appState.authorizationStatus == .approved &&
        !appState.selectedTargets.isEmpty &&
        appState.timeBank.remainingSeconds > 0
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

/// Circular stat card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

/// Compact task row for dashboard
struct DashboardTaskRow: View {
    let task: RewardTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .secondary)

                Text(task.title)
                    .font(.body)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)

                Spacer()

                Text("+\(task.rewardMinutes)m")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Row for completed tasks in the Completed Tasks section
struct CompletedTaskRow: View {
    let task: RewardTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)

                Text(task.title)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .strikethrough()
                    .lineLimit(1)

                Spacer()

                Text("+\(task.rewardMinutes)m")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Activity event row for dashboard
struct ActivityEventRow: View {
    let event: ActivityEvent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.type.iconName)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.type.displayText)
                    .font(.body)
                    .foregroundColor(.primary)

                if let detail = event.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(formatTime(event.timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var iconColor: Color {
        switch event.type {
        case .sessionStarted: return .green
        case .sessionEnded: return .red
        case .taskCompleted: return .blue
        case .taskUncompleted: return .gray
        case .timeAdded: return .orange
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
