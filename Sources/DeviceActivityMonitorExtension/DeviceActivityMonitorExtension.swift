import DeviceActivity
import ManagedSettings
import Foundation

/// Extension that monitors device activity and triggers re-lock when balance is exhausted
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore()
    private let storage = SharedStorage.shared

    /// Called when monitoring begins for a scheduled interval
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        // Record monitor event
        var state = storage.loadEnforcementState()
        state.recordMonitorEvent()
        storage.saveEnforcementState(state)

        // Check if we should remove shields (session active)
        let session = storage.loadActiveSession()
        if session.isActive {
            removeShields()
        } else {
            applyShields()
        }
    }

    /// Called when monitoring ends for a scheduled interval
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        // Check session status
        let session = storage.loadActiveSession()

        if session.isActive {
            // Session is still active - check if time expired
            let elapsed = session.elapsedSeconds + session.consumedSeconds

            if elapsed >= session.grantedSeconds {
                // Time exhausted - re-apply shields
                applyShields()

                // End session
                var updatedSession = session
                updatedSession.stop()
                storage.saveActiveSession(updatedSession)
            }
        }

        // Record monitor event
        var state = storage.loadEnforcementState()
        state.recordMonitorEvent()
        storage.saveEnforcementState(state)
    }

    /// Called when the device activity interval reaches its end
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        // Check if time is exhausted
        let session = storage.loadActiveSession()

        if session.isActive {
            let elapsed = session.elapsedSeconds + session.consumedSeconds

            if elapsed >= session.grantedSeconds {
                // Time exhausted - re-apply shields
                applyShields()

                // End session
                var updatedSession = session
                updatedSession.stop()
                storage.saveActiveSession(updatedSession)
            }
        }
    }

    /// Called when an interval is going to be interrupted
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }

    /// Called when an interval is going to end early
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }

    // MARK: - Shield Management

    private func applyShields() {
        guard let targets = storage.loadSelectedTargets() else { return }

        store.shield.applications = targets.applications.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(targets.categories.categoryTokens)
        store.shield.webDomains = targets.webDomains.webDomainTokens

        var state = storage.loadEnforcementState()
        state.applyShield()
        storage.saveEnforcementState(state)

        print("[DeviceActivityMonitor] Shields applied")
    }

    private func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        var state = storage.loadEnforcementState()
        state.removeShield()
        storage.saveEnforcementState(state)

        print("[DeviceActivityMonitor] Shields removed")
    }
}
