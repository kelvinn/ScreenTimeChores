import SwiftUI

/// Sheet for adding or editing a task
struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss

    let task: RewardTask?
    let onSave: (RewardTask) -> Void

    @State private var title: String = ""
    @State private var rewardMinutes: Int = 15
    @State private var category: TaskCategory = .home
    @State private var scheduleType: ScheduleType = .allDays
    @State private var selectedDays: Set<DayOfWeek> = Set(DayOfWeek.allCases)

    init(task: RewardTask? = nil, onSave: @escaping (RewardTask) -> Void) {
        self.task = task
        self.onSave = onSave

        if let task = task {
            _title = State(initialValue: task.title)
            _rewardMinutes = State(initialValue: task.rewardMinutes)
            _category = State(initialValue: task.category)
            _scheduleType = State(initialValue: task.scheduleType)
            _selectedDays = State(initialValue: task.selectedDays)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Task Details Section
                Section {
                    TextField("Task title", text: $title)

                    Stepper("Reward: \(rewardMinutes) minutes", value: $rewardMinutes, in: 5...120, step: 5)
                } header: {
                    Text("Task Details")
                }

                // Category Section
                Section {
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.iconName)
                                .tag(cat)
                        }
                    }
                } header: {
                    Text("Category")
                }

                // Schedule Section
                Section {
                    Picker("Schedule", selection: $scheduleType) {
                        ForEach(ScheduleType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    if scheduleType == .custom {
                        DayOfWeekPicker(selectedDays: $selectedDays)
                    }
                } header: {
                    Text("Schedule")
                } footer: {
                    Text(scheduleDescription)
                }
            }
            .navigationTitle(task == nil ? "Add Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var scheduleDescription: String {
        switch scheduleType {
        case .allDays:
            return "This task will appear every day"
        case .weekdays:
            return "This task will appear Monday through Friday"
        case .weekends:
            return "This task will appear on weekends"
        case .custom:
            if selectedDays.isEmpty {
                return "Select at least one day"
            }
            let sortedDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
            return "This task will appear on \(sortedDays.map { $0.shortName }.joined(separator: " "))"
        }
    }

    private func saveTask() {
        let newTask = RewardTask(
            id: task?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespaces),
            rewardMinutes: rewardMinutes,
            isEnabled: task?.isEnabled ?? true,
            category: category,
            scheduleType: scheduleType,
            selectedDays: scheduleType == .custom ? selectedDays : Set(DayOfWeek.allCases),
            isCompleted: task?.isCompleted ?? false
        )
        onSave(newTask)
        dismiss()
    }
}

/// Custom day picker for selecting multiple days
struct DayOfWeekPicker: View {
    @Binding var selectedDays: Set<DayOfWeek>

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(DayOfWeek.allCases) { day in
                    DayButton(day: day, isSelected: selectedDays.contains(day)) {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

/// Individual day button
struct DayButton: View {
    let day: DayOfWeek
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(day.shortName)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 36, height: 36)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
