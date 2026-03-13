import Foundation
import FamilyControls

// MARK: - Selected Targets
/// Stores the FamilyActivityPicker selections as opaque tokens
struct SelectedTargets: Codable, Equatable {
    var applications: FamilyActivitySelection
    var categories: FamilyActivitySelection
    var webDomains: FamilyActivitySelection

    var isEmpty: Bool {
        applications.applicationTokens.isEmpty &&
        categories.categoryTokens.isEmpty &&
        webDomains.webDomainTokens.isEmpty
    }

    var totalCount: Int {
        applications.applicationTokens.count +
        categories.categoryTokens.count +
        webDomains.webDomainTokens.count
    }
}

// MARK: - Day of Week
enum DayOfWeek: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }

    static var weekdays: Set<DayOfWeek> {
        [.monday, .tuesday, .wednesday, .thursday, .friday]
    }

    static var weekends: Set<DayOfWeek> {
        [.saturday, .sunday]
    }
}

// MARK: - Task Category
enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case home
    case work
    case personal
    case health

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        case .personal: return "Personal"
        case .health: return "Health"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        }
    }

    var color: String {
        switch self {
        case .home: return "orange"
        case .work: return "blue"
        case .personal: return "purple"
        case .health: return "red"
        }
    }
}

// MARK: - Schedule Type
enum ScheduleType: String, Codable, CaseIterable, Identifiable {
    case allDays
    case weekdays
    case weekends
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .allDays: return "Every Day"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .custom: return "Custom"
        }
    }
}

// MARK: - Task Filter
enum TaskFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case weekdays
    case weekends
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .today: return "Today"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .custom: return "Custom"
        }
    }
}

// MARK: - Reward Task
/// A task that can be completed to earn time
struct RewardTask: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var rewardMinutes: Int
    var isEnabled: Bool
    var category: TaskCategory
    var scheduleType: ScheduleType
    var selectedDays: Set<DayOfWeek>
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        rewardMinutes: Int,
        isEnabled: Bool = true,
        category: TaskCategory = .home,
        scheduleType: ScheduleType = .allDays,
        selectedDays: Set<DayOfWeek> = Set(DayOfWeek.allCases),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.rewardMinutes = rewardMinutes
        self.isEnabled = isEnabled
        self.category = category
        self.scheduleType = scheduleType
        self.selectedDays = selectedDays
        self.isCompleted = isCompleted
    }

    var rewardSeconds: Int {
        rewardMinutes * 60
    }

    var scheduleDescription: String {
        switch scheduleType {
        case .allDays:
            return "Every day"
        case .weekdays:
            return "Every weekday"
        case .weekends:
            return "Every weekend"
        case .custom:
            if selectedDays.count == 7 {
                return "Every day"
            } else if selectedDays == DayOfWeek.weekdays {
                return "Every weekday"
            } else if selectedDays == DayOfWeek.weekends {
                return "Every weekend"
            } else {
                let sortedDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
                return sortedDays.map { $0.shortName }.joined(separator: " ")
            }
        }
    }

    func isScheduledFor(day: DayOfWeek) -> Bool {
        switch scheduleType {
        case .allDays:
            return true
        case .weekdays:
            return DayOfWeek.weekdays.contains(day)
        case .weekends:
            return DayOfWeek.weekends.contains(day)
        case .custom:
            return selectedDays.contains(day)
        }
    }
}

// MARK: - Time Bank
/// Stores the user's banked time balance
struct TimeBank: Codable, Equatable {
    var totalBankedSeconds: Int
    var remainingSeconds: Int
    var lastUpdatedAt: Date

    init(totalBankedSeconds: Int = 0, remainingSeconds: Int = 0, lastUpdatedAt: Date = Date()) {
        self.totalBankedSeconds = totalBankedSeconds
        self.remainingSeconds = remainingSeconds
        self.lastUpdatedAt = lastUpdatedAt
    }

    var remainingMinutes: Int {
        remainingSeconds / 60
    }

    var totalBankedMinutes: Int {
        totalBankedSeconds / 60
    }

    mutating func addTime(minutes: Int) {
        let seconds = minutes * 60
        totalBankedSeconds += seconds
        remainingSeconds += seconds
        lastUpdatedAt = Date()
    }

    mutating func subtractTime(minutes: Int) {
        let seconds = minutes * 60
        totalBankedSeconds = max(0, totalBankedSeconds - seconds)
        remainingSeconds = max(0, remainingSeconds - seconds)
        lastUpdatedAt = Date()
    }

    mutating func consumeTime(seconds: Int) {
        remainingSeconds = max(0, remainingSeconds - seconds)
        lastUpdatedAt = Date()
    }
}

// MARK: - Active Session
/// Tracks the current reward session state
struct ActiveSession: Codable, Equatable {
    var isActive: Bool
    var startedAt: Date?
    var grantedSeconds: Int
    var consumedSeconds: Int
    var targetSelectionVersion: Int

    init(isActive: Bool = false, startedAt: Date? = nil, grantedSeconds: Int = 0, consumedSeconds: Int = 0, targetSelectionVersion: Int = 0) {
        self.isActive = isActive
        self.startedAt = startedAt
        self.grantedSeconds = grantedSeconds
        self.consumedSeconds = consumedSeconds
        self.targetSelectionVersion = targetSelectionVersion
    }

    var remainingSeconds: Int {
        max(0, grantedSeconds - consumedSeconds)
    }

    var remainingMinutes: Int {
        remainingSeconds / 60
    }

    var elapsedSeconds: Int {
        guard let startedAt = startedAt else { return 0 }
        return Int(Date().timeIntervalSince(startedAt))
    }

    mutating func start(grantedSeconds: Int, targetVersion: Int) {
        isActive = true
        startedAt = Date()
        self.grantedSeconds = grantedSeconds
        consumedSeconds = 0
        targetSelectionVersion = targetVersion
    }

    mutating func stop() {
        isActive = false
        startedAt = nil
        grantedSeconds = 0
        consumedSeconds = 0
    }
}

// MARK: - Enforcement State
/// Tracks the current shield enforcement state
struct EnforcementState: Codable, Equatable {
    var shieldApplied: Bool
    var totalShieldedSeconds: Int
    var lastShieldAppliedAt: Date?
    var lastShieldRemovedAt: Date?
    var lastMonitorEventAt: Date?
    var lastError: String?

    init(shieldApplied: Bool = false, totalShieldedSeconds: Int = 0, lastShieldAppliedAt: Date? = nil, lastShieldRemovedAt: Date? = nil, lastMonitorEventAt: Date? = nil, lastError: String? = nil) {
        self.shieldApplied = shieldApplied
        self.totalShieldedSeconds = totalShieldedSeconds
        self.lastShieldAppliedAt = lastShieldAppliedAt
        self.lastShieldRemovedAt = lastShieldRemovedAt
        self.lastMonitorEventAt = lastMonitorEventAt
        self.lastError = lastError
    }

    var totalShieldedMinutes: Int {
        totalShieldedSeconds / 60
    }

    mutating func applyShield() {
        // If shields were previously applied, add the elapsed time to total
        if shieldApplied, let lastApplied = lastShieldAppliedAt {
            let elapsed = Int(Date().timeIntervalSince(lastApplied))
            totalShieldedSeconds += elapsed
        }
        shieldApplied = true
        lastShieldAppliedAt = Date()
    }

    mutating func removeShield() {
        // Add elapsed time before removing
        if shieldApplied, let lastApplied = lastShieldAppliedAt {
            let elapsed = Int(Date().timeIntervalSince(lastApplied))
            totalShieldedSeconds += elapsed
        }
        shieldApplied = false
        lastShieldRemovedAt = Date()
    }

    mutating func recordMonitorEvent() {
        lastMonitorEventAt = Date()
    }

    mutating func recordError(_ error: String) {
        lastError = error
    }
}

// MARK: - Authorization Status
/// Tracks the FamilyControls authorization status
enum AuthorizationStatus: String, Codable {
    case notDetermined
    case denied
    case approved
}

// MARK: - Activity Event
/// Types of activity events for the recent activity feed
enum ActivityEventType: String, Codable {
    case sessionStarted
    case sessionEnded
    case taskCompleted
    case taskUncompleted
    case timeAdded

    var iconName: String {
        switch self {
        case .sessionStarted: return "play.circle.fill"
        case .sessionEnded: return "stop.circle.fill"
        case .taskCompleted: return "checkmark.circle.fill"
        case .taskUncompleted: return "xmark.circle.fill"
        case .timeAdded: return "plus.circle.fill"
        }
    }

    var displayText: String {
        switch self {
        case .sessionStarted: return "Reward session started"
        case .sessionEnded: return "Reward session ended"
        case .taskCompleted: return "Completed task"
        case .taskUncompleted: return "Uncompleted task"
        case .timeAdded: return "Time added"
        }
    }
}

/// Records an activity event for the recent activity feed
struct ActivityEvent: Codable, Identifiable, Equatable {
    let id: UUID
    let type: ActivityEventType
    let timestamp: Date
    let detail: String?

    init(id: UUID = UUID(), type: ActivityEventType, timestamp: Date = Date(), detail: String? = nil) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.detail = detail
    }
}
