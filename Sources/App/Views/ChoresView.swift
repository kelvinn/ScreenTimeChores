import SwiftUI

/// Main chores view with filtering, category grouping, and task management
struct ChoresView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddTask = false
    @State private var taskToEdit: RewardTask?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $appState.taskFilter) {
                    ForEach(TaskFilter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Task List
                if appState.filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    taskList
                }
            }
            .navigationTitle("Chores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet { task in
                    appState.addTask(task)
                }
            }
            .sheet(item: $taskToEdit) { task in
                AddTaskSheet(task: task) { updatedTask in
                    appState.updateTask(updatedTask)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Tasks")
                .font(.headline)

            Text("Tap + to add a new task")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                ForEach(TaskCategory.allCases) { category in
                    if let tasks = appState.tasksByCategory[category], !tasks.isEmpty {
                        Section {
                            VStack(spacing: 0) {
                                ForEach(tasks) { task in
                                    ChoreTaskRow(task: task) {
                                        appState.toggleTaskCompletion(task)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            appState.deleteTask(task)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            taskToEdit = task
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }

                                    if task.id != tasks.last?.id {
                                        Divider()
                                            .padding(.leading, 56)
                                    }
                                }
                            }
                        } header: {
                            CategoryHeader(category: category, taskCount: tasks.count)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80)
        }
    }
}

/// Category section header
struct CategoryHeader: View {
    let category: TaskCategory
    let taskCount: Int

    var body: some View {
        HStack {
            Image(systemName: category.iconName)
                .foregroundColor(Color(category.color))
                .frame(width: 24, height: 24)

            Text(category.displayName)
                .font(.headline)

            Spacer()

            Text("\(taskCount)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGroupedBackground))
    }
}

/// Individual chore task row
struct ChoreTaskRow: View {
    let task: RewardTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Completion checkbox
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .secondary)

                // Task details
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted)

                    // Day indicators and schedule
                    HStack(spacing: 4) {
                        ForEach(DayOfWeek.allCases) { day in
                            DayIndicator(
                                day: day,
                                isSelected: task.isScheduledFor(day: day)
                            )
                        }
                    }
                }

                Spacer()

                // Reward badge
                VStack(alignment: .trailing, spacing: 2) {
                    Text("+\(task.rewardMinutes)")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)

                    Text("min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Day of week indicator circle
struct DayIndicator: View {
    let day: DayOfWeek
    let isSelected: Bool

    var body: some View {
        Text(day.shortName)
            .font(.caption2)
            .fontWeight(.medium)
            .frame(width: 20, height: 20)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .secondary)
            .clipShape(Circle())
    }
}
