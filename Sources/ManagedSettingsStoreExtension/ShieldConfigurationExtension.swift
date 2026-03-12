import UIKit
import ManagedSettings
import ManagedSettingsUI
import FamilyControls

/// Extension that applies and removes shields based on stored configuration
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let store = ManagedSettingsStore()
    private let storage = SharedStorage.shared

    override init() {
        super.init()
        applyStoredConfiguration()
    }

    /// Apply shields based on stored selected targets
    private func applyStoredConfiguration() {
        // Check if we should apply shields
        let session = storage.loadActiveSession()

        // If session is active, don't apply shields
        if session.isActive {
            return
        }

        // Apply shields for locked state
        applyShields()
    }

    private func applyShields() {
        guard let targets = storage.loadSelectedTargets() else { return }

        // Apply shields to applications
        store.shield.applications = targets.applications.applicationTokens

        // Apply shields to categories
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(targets.categories.categoryTokens)

        // Apply shields to web domains
        store.shield.webDomains = targets.webDomains.webDomainTokens

        // Update enforcement state
        var state = storage.loadEnforcementState()
        state.applyShield()
        storage.saveEnforcementState(state)
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        ShieldConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }
}
