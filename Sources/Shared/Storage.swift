import Foundation
import FamilyControls

/// App Group identifier for sharing data between app and extensions
let appGroupIdentifier = "group.com.rewardsield.app"

/// Keys for UserDefaults storage
enum StorageKey: String {
    case selectedTargets = "selectedTargets"
    case timeBank = "timeBank"
    case activeSession = "activeSession"
    case enforcementState = "enforcementState"
    case authorizationStatus = "authorizationStatus"
    case rewardTasks = "rewardTasks"
    case targetSelectionVersion = "targetSelectionVersion"
}

/// Shared storage using App Group UserDefaults
/// Provides cross-process access for app and all extensions
final class SharedStorage {
    static let shared = SharedStorage()

    private let defaults: UserDefaults

    private init() {
        guard let groupDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            fatalError("Failed to initialize App Group UserDefaults")
        }
        self.defaults = groupDefaults
    }

    // MARK: - Selected Targets

    func saveSelectedTargets(_ targets: SelectedTargets) {
        do {
            let data = try PropertyListEncoder().encode(targets)
            defaults.set(data, forKey: StorageKey.selectedTargets.rawValue)
            incrementTargetSelectionVersion()
        } catch {
            print("Failed to save selected targets: \(error)")
        }
    }

    func loadSelectedTargets() -> SelectedTargets? {
        guard let data = defaults.data(forKey: StorageKey.selectedTargets.rawValue) else {
            return nil
        }
        do {
            return try PropertyListDecoder().decode(SelectedTargets.self, from: data)
        } catch {
            print("Failed to load selected targets: \(error)")
            return nil
        }
    }

    func clearSelectedTargets() {
        defaults.removeObject(forKey: StorageKey.selectedTargets.rawValue)
    }

    // MARK: - Time Bank

    func saveTimeBank(_ timeBank: TimeBank) {
        do {
            let data = try PropertyListEncoder().encode(timeBank)
            defaults.set(data, forKey: StorageKey.timeBank.rawValue)
        } catch {
            print("Failed to save time bank: \(error)")
        }
    }

    func loadTimeBank() -> TimeBank {
        guard let data = defaults.data(forKey: StorageKey.timeBank.rawValue),
              let timeBank = try? PropertyListDecoder().decode(TimeBank.self, from: data) else {
            return TimeBank()
        }
        return timeBank
    }

    // MARK: - Active Session

    func saveActiveSession(_ session: ActiveSession) {
        do {
            let data = try PropertyListEncoder().encode(session)
            defaults.set(data, forKey: StorageKey.activeSession.rawValue)
        } catch {
            print("Failed to save active session: \(error)")
        }
    }

    func loadActiveSession() -> ActiveSession {
        guard let data = defaults.data(forKey: StorageKey.activeSession.rawValue),
              let session = try? PropertyListDecoder().decode(ActiveSession.self, from: data) else {
            return ActiveSession()
        }
        return session
    }

    // MARK: - Enforcement State

    func saveEnforcementState(_ state: EnforcementState) {
        do {
            let data = try PropertyListEncoder().encode(state)
            defaults.set(data, forKey: StorageKey.enforcementState.rawValue)
        } catch {
            print("Failed to save enforcement state: \(error)")
        }
    }

    func loadEnforcementState() -> EnforcementState {
        guard let data = defaults.data(forKey: StorageKey.enforcementState.rawValue),
              let state = try? PropertyListDecoder().decode(EnforcementState.self, from: data) else {
            return EnforcementState()
        }
        return state
    }

    // MARK: - Authorization Status

    func saveAuthorizationStatus(_ status: AuthorizationStatus) {
        defaults.set(status.rawValue, forKey: StorageKey.authorizationStatus.rawValue)
    }

    func loadAuthorizationStatus() -> AuthorizationStatus {
        guard let rawValue = defaults.string(forKey: StorageKey.authorizationStatus.rawValue),
              let status = AuthorizationStatus(rawValue: rawValue) else {
            return .notDetermined
        }
        return status
    }

    // MARK: - Reward Tasks

    func saveRewardTasks(_ tasks: [RewardTask]) {
        do {
            let data = try PropertyListEncoder().encode(tasks)
            defaults.set(data, forKey: StorageKey.rewardTasks.rawValue)
        } catch {
            print("Failed to save reward tasks: \(error)")
        }
    }

    func loadRewardTasks() -> [RewardTask] {
        guard let data = defaults.data(forKey: StorageKey.rewardTasks.rawValue),
              let tasks = try? PropertyListDecoder().decode([RewardTask].self, from: data) else {
            return Self.defaultRewardTasks
        }
        return tasks
    }

    // MARK: - Target Selection Version

    func getTargetSelectionVersion() -> Int {
        defaults.integer(forKey: StorageKey.targetSelectionVersion.rawValue)
    }

    func incrementTargetSelectionVersion() {
        let current = getTargetSelectionVersion()
        defaults.set(current + 1, forKey: StorageKey.targetSelectionVersion.rawValue)
    }

    // MARK: - Clear All

    func clearAll() {
        let keys: [StorageKey] = [
            .selectedTargets, .timeBank, .activeSession,
            .enforcementState, .authorizationStatus,
            .rewardTasks, .targetSelectionVersion
        ]
        keys.forEach { defaults.removeObject(forKey: $0.rawValue) }
    }

    // MARK: - Default Tasks

    static let defaultRewardTasks: [RewardTask] = [
        RewardTask(title: "Complete homework", rewardMinutes: 30),
        RewardTask(title: "Read for 20 minutes", rewardMinutes: 20),
        RewardTask(title: "Clean room", rewardMinutes: 15),
        RewardTask(title: "Help with chores", rewardMinutes: 15),
        RewardTask(title: "Practice instrument", rewardMinutes: 20),
        RewardTask(title: "Exercise / Sports", rewardMinutes: 20),
        RewardTask(title: "Complete chores", rewardMinutes: 10)
    ]
}
