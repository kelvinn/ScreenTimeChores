# Reward Shield POC

An iOS proof-of-concept app that uses Apple's Screen Time APIs to implement a "time-as-currency" model. Selected apps/categories are blocked by default, time is earned through tasks, and access is restored temporarily until earned time is consumed, after which shields are re-applied automatically.

## What Was Built

### Core Features
- **Authorization Flow**: Requests Screen Time authorization using FamilyControls
- **Target Selection**: FamilyActivityPicker integration for selecting apps/categories/websites to block
- **Default Locked State**: Shields applied to selected targets by default
- **Time Banking**: Manual time addition and reward-based time earning
- **Task Catalog**: Predefined tasks with reward values
- **Session Management**: Start/stop reward sessions that temporarily unlock apps
- **Usage Monitoring**: DeviceActivity monitoring during sessions
- **Auto Re-Lock**: Automatic shield restoration when balance is exhausted
- **State Recovery**: Graceful handling of app termination and device restart
- **Diagnostics UI**: Status display for debugging and transparency

### Technical Architecture

```
RewardShield (Host App)
├── App State Management (AppState.swift)
├── Views (SwiftUI)
│   ├── ContentView.swift (Tab navigation)
│   ├── SetupView.swift (Authorization & target selection)
│   ├── RewardsView.swift (Time banking & tasks)
│   ├── SessionView.swift (Session control)
│   └── StatusView.swift (Diagnostics)
└── Shared
    ├── Models.swift (Data models)
    └── Storage.swift (App Group persistence)

Extensions:
├── ManagedSettingsStoreExtension
│   └── ShieldConfigurationExtension.swift (Shield management)
├── DeviceActivityMonitorExtension
│   └── DeviceActivityMonitorExtension.swift (Usage monitoring)
└── ShieldUIExtension
    └── ShieldUIExtension.swift (Native shield UI)
```

### Key Implementation Decisions

1. **Individual Authorization**: Uses `.individual` authorization (not child account) per PRD constraints
2. **App Group Storage**: All state shared via App Group UserDefaults for cross-process access
3. **Extension-Driven Enforcement**: Host app may be terminated; enforcement relies on extensions
4. **Opaque Tokens**: FamilyActivitySelection stored as-is (not decoded)
5. **Minimal Architecture**: No backend, all on-device

## Setup Steps

1. **XcodeGen Required**: Install XcodeGen (`brew install xcodegen`)
2. **Generate Project**: Run `xcodegen generate`
3. **Configure Development Team**: Set your team ID in project.yml
4. **Capabilities Required**:
   - Family Controls
   - App Groups (`group.com.rewardsield.app`)
5. **Build & Run**: Open `RewardShield.xcodeproj`

## Assumptions Made from PRD

- **Individual Authorization**: User is on their own device (not parental control for child)
- **iOS 16+**: Uses Screen Time APIs introduced in iOS 16
- **No Anti-Tamper**: Under individual authorization, user can disable in Settings
- **Timing Tolerance**: Re-lock may not occur at exact second (per Constraint E)
- **Single Device**: Same physical device for setup and enforcement

## Functional Requirements Coverage

| FR | Status | Implementation |
|----|--------|----------------|
| FR-01 Authorization | ✅ | AuthorizationCenter.requestAuthorization |
| FR-02 Target Selection | ✅ | FamilyActivityPicker |
| FR-03 Default Locked State | ✅ | ManagedSettingsStore shields |
| FR-04 Time Banking | ✅ | TimeBank model + UI |
| FR-05 Task Catalog | ✅ | RewardTask model + list |
| FR-06 Session Start | ✅ | ActiveSession management |
| FR-07 Usage Monitoring | ✅ | DeviceActivityMonitor |
| FR-08 Auto Re-Lock | ✅ | Extension triggers shield |
| FR-09 State Recovery | ✅ | App lifecycle handling |
| FR-10 Explainability | ✅ | StatusView diagnostics |

## Remaining Gaps / Known Issues

1. **Build Environment**: Requires valid Xcode simulator or device to build (CoreSimulator service required)
2. **Entitlements**: Need valid provisioning profiles with Family Controls entitlement from Apple Developer Portal
3. **Shield Customization**: Could enhance with more customization options

## Unit Tests

Core logic is tested in `Sources/AppTests/CoreModelsTests.swift`:
- TimeBankTests: addTime, consumeTime, remainingMinutes
- ActiveSessionTests: start, stop, remainingSeconds, elapsedSeconds
- RewardTaskTests: rewardSeconds, defaultEnabled
- EnforcementStateTests: applyShield, removeShield, recordError

## Platform Limitations Documented

Per PRD Section 7 (Key Platform Constraints):
- Cannot edit Apple's Screen Time UI directly
- Individual authorization is weaker than child-account
- Background enforcement is extension-driven
- Timing may not be perfectly exact

## Testing Recommendations

Per PRD Section 17:
- App relaunch
- Force quit
- Device restart
- Low battery mode
- Authorization revoked
- Target set changes
- Multiple short sessions
