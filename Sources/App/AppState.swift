import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Main app state manager - handles all business logic
@MainActor
final class AppState: ObservableObject {
    // MARK: - Published Properties

    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selectedTargets: SelectedTargets = SelectedTargets(
        applications: FamilyActivitySelection(),
        categories: FamilyActivitySelection(),
        webDomains: FamilyActivitySelection()
    )
    @Published var timeBank: TimeBank = TimeBank()
    @Published var activeSession: ActiveSession = ActiveSession()
    @Published var enforcementState: EnforcementState = EnforcementState()
    @Published var rewardTasks: [RewardTask] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let storage = SharedStorage.shared
    private let store = ManagedSettingsStore()

    // MARK: - Initialization

    init() {
        loadState()
    }

    // MARK: - State Loading

    func loadState() {
        authorizationStatus = storage.loadAuthorizationStatus()
        selectedTargets = storage.loadSelectedTargets() ?? SelectedTargets(
            applications: FamilyActivitySelection(),
            categories: FamilyActivitySelection(),
            webDomains: FamilyActivitySelection()
        )
        timeBank = storage.loadTimeBank()
        activeSession = storage.loadActiveSession()
        enforcementState = storage.loadEnforcementState()
        rewardTasks = storage.loadRewardTasks()
    }

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = .approved
            storage.saveAuthorizationStatus(.approved)
        } catch {
            authorizationStatus = .denied
            storage.saveAuthorizationStatus(.denied)
            errorMessage = "Authorization failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Target Selection

    func updateSelectedTargets(_ targets: SelectedTargets) {
        selectedTargets = targets
        storage.saveSelectedTargets(targets)

        // Re-apply shields if not in active session
        if !activeSession.isActive {
            applyShields()
        }
    }

    // MARK: - Time Banking

    func addTime(minutes: Int) {
        timeBank.addTime(minutes: minutes)
        storage.saveTimeBank(timeBank)
    }

    func earnReward(for task: RewardTask) {
        addTime(minutes: task.rewardMinutes)
    }

    // MARK: - Session Management

    func startSession() {
        guard timeBank.remainingSeconds > 0 else {
            errorMessage = "No time available to start session"
            return
        }

        // Remove shields to allow access
        removeShields()

        // Start device activity monitoring
        startMonitoring()

        // Update session state
        activeSession.start(
            grantedSeconds: timeBank.remainingSeconds,
            targetVersion: storage.getTargetSelectionVersion()
        )

        storage.saveActiveSession(activeSession)
    }

    func stopSession() {
        // Stop monitoring
        stopMonitoring()

        // Re-apply shields
        applyShields()

        // Update session
        activeSession.stop()
        storage.saveActiveSession(activeSession)
    }

    // MARK: - Shield Management

    func applyShields() {
        let targets = storage.loadSelectedTargets()
        guard let targets = targets, !targets.isEmpty else { return }

        store.shield.applications = targets.applications.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(targets.categories.categoryTokens)
        store.shield.webDomains = targets.webDomains.webDomainTokens

        enforcementState.applyShield()
        storage.saveEnforcementState(enforcementState)
    }

    func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        enforcementState.removeShield()
        storage.saveEnforcementState(enforcementState)
    }

    // MARK: - Device Activity Monitoring

    private func startMonitoring() {
        let center = DeviceActivityCenter()
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        do {
            try center.startMonitoring(DeviceActivityName("shielded"), during: schedule)
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }

    private func stopMonitoring() {
        let center = DeviceActivityCenter()
        center.stopMonitoring([DeviceActivityName("shielded")])
    }

    // MARK: - State Recovery

    func recoverState() {
        loadState()

        // If session was active but app was killed, check if time expired
        if activeSession.isActive {
            let elapsed = activeSession.elapsedSeconds
            let consumed = activeSession.consumedSeconds + elapsed

            if consumed >= activeSession.grantedSeconds {
                // Time expired - re-apply shields
                applyShields()
                activeSession.stop()
                storage.saveActiveSession(activeSession)
            }
        } else if enforcementState.shieldApplied {
            // Ensure shields are applied in locked state
            applyShields()
        }
    }

    // MARK: - Reset

    func resetAll() {
        stopSession()
        storage.clearAll()
        loadState()
    }
}
