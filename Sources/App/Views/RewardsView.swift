import SwiftUI

/// Rewards view for earning and managing time
struct RewardsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddTime = false

    var body: some View {
        NavigationStack {
            List {
                // Balance Section
                Section {
                    BalanceCard(timeBank: appState.timeBank)
                }

                // Add Time Section
                Section {
                    Button {
                        showingAddTime = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Add Time Manually")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Quick Add")
                }

                // Tasks Section
                Section {
                    ForEach(appState.rewardTasks) { task in
                        TaskRow(task: task) {
                            appState.earnReward(for: task)
                        }
                    }
                } header: {
                    Text("Earn Time")
                } footer: {
                    Text("Tap a task to add its reward to your balance.")
                }
            }
            .navigationTitle("Rewards")
            .sheet(isPresented: $showingAddTime) {
                AddTimeSheet(timeBank: appState.timeBank) { minutes in
                    appState.addTime(minutes: minutes)
                }
            }
        }
    }
}

/// Balance display card
struct BalanceCard: View {
    let timeBank: TimeBank

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(timeBank.remainingMinutes)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("minutes remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Earned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(timeBank.totalBankedMinutes)")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Text("minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Progress bar
            if timeBank.totalBankedSeconds > 0 {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(
                                width: geometry.size.width * CGFloat(timeBank.remainingSeconds) / CGFloat(timeBank.totalBankedSeconds),
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// Task row for earning rewards
struct TaskRow: View {
    let task: RewardTask
    let onComplete: () -> Void

    var body: some View {
        Button {
            onComplete()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)

                Text(task.title)
                    .foregroundColor(.primary)

                Spacer()

                Text("+\(task.rewardMinutes) min")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
            }
        }
    }
}

/// Add time sheet
struct AddTimeSheet: View {
    @Environment(\.dismiss) private var dismiss
    let timeBank: TimeBank
    let onAdd: (Int) -> Void

    @State private var minutes: Int = 15

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper("Minutes: \(minutes)", value: $minutes, in: 5...120, step: 5)
                } header: {
                    Text("Add Time")
                }

                Section {
                    Button("Add \(minutes) Minutes") {
                        onAdd(minutes)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Add Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

