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

// MARK: - Reward Task
/// A task that can be completed to earn time
struct RewardTask: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var rewardMinutes: Int
    var isEnabled: Bool

    init(id: UUID = UUID(), title: String, rewardMinutes: Int, isEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.rewardMinutes = rewardMinutes
        self.isEnabled = isEnabled
    }

    var rewardSeconds: Int {
        rewardMinutes * 60
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
    var lastShieldAppliedAt: Date?
    var lastShieldRemovedAt: Date?
    var lastMonitorEventAt: Date?
    var lastError: String?

    init(shieldApplied: Bool = false, lastShieldAppliedAt: Date? = nil, lastShieldRemovedAt: Date? = nil, lastMonitorEventAt: Date? = nil, lastError: String? = nil) {
        self.shieldApplied = shieldApplied
        self.lastShieldAppliedAt = lastShieldAppliedAt
        self.lastShieldRemovedAt = lastShieldRemovedAt
        self.lastMonitorEventAt = lastMonitorEventAt
        self.lastError = lastError
    }

    mutating func applyShield() {
        shieldApplied = true
        lastShieldAppliedAt = Date()
    }

    mutating func removeShield() {
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
