import UIKit
import ManagedSettings
import ManagedSettingsUI

/// Extension that presents the native shield UI when blocked apps are opened
class ShieldUIExtension: ShieldConfigurationDataSource {

    override init() {
        super.init()
    }

    /// Customize the shield for applications
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        ShieldConfiguration()
    }

    /// Customize the shield for application categories
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }

    /// Customize the shield for web domains
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration()
    }

    /// Customize the shield for web domain categories
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }
}
