# Implementation Tasks - Reward Shield POC

## Overview
This file contains atomic implementation tasks derived from the PRD.md specification.

## Phase 1: Project Setup

### T1.1: XcodeGen Configuration
- Create `project.yml` with all targets
- Configure entitlements for FamilyControls, ManagedSettings, DeviceActivity
- Set up App Group capability
- Define directory structure for all extensions

### T1.2: Directory Structure
- Create `Sources/App/` for host app
- Create `Sources/Shared/` for models and storage
- Create `Sources/ManagedSettingsStoreExtension/`
- Create `Sources/DeviceActivityMonitorExtension/`
- Create `Sources/ShieldUIExtension/`

---

## Phase 2: Shared Module

### T2.1: Data Models
Create `Sources/Shared/Models.swift`:
- `SelectedTargets` - application tokens, category tokens, web domain tokens
- `RewardTask` - id, title, rewardMinutes, enabled
- `TimeBank` - totalBankedSeconds, remainingSeconds, lastUpdatedAt
- `ActiveSession` - isActive, startedAt, grantedSeconds, consumedSeconds, targetSelectionVersion
- `EnforcementState` - shieldApplied, lastShieldAppliedAt, lastShieldRemovedAt, lastMonitorEventAt, lastError

### T2.2: App Group Storage
Create `Sources/Shared/Storage.swift`:
- App Group UserDefaults wrapper
- Codable persistence for all models
- Cross-process access for extensions

---

## Phase 3: Authorization (FR-01)

### T3.1: Authorization Flow
- Request FamilyControls authorization using AuthorizationCenter
- Handle authorization status changes
- Surface authorization state in UI

### T3.2: Authorization UI
- Display authorization status
- Block POC flows until authorized

---

## Phase 4: Target Selection (FR-02)

### T4.1: FamilyActivityPicker Integration
- Integrate FamilyActivityPicker
- Store selected opaque tokens
- Allow editing selections

### T4.2: Target Persistence
- Persist selections across launches
- Store in App Group shared storage

---

## Phase 5: Shield Management (FR-03, FR-08)

### T5.1: Managed Settings Store Extension
- Create ShieldConfigurationExtension
- Apply shields to selected targets
- Remove shields when session starts
- Re-apply shields when balance exhausted

### T5.2: Shield UI Extension
- Present native restriction experience
- Custom title and message
- Use ShieldConfiguration and ShieldUIDataProvider

---

## Phase 6: Device Activity Monitoring (FR-07, FR-08)

### T6.1: Device Activity Monitor Extension
- Create DeviceActivityMonitor extension
- Implement intervalDidStart/intervalDidEnd callbacks
- Detect balance exhaustion

### T6.2: Usage Tracking
- Monitor usage of selected targets
- Track consumed time against balance
- Trigger re-lock in background

---

## Phase 7: Time Banking (FR-04, FR-05)

### T7.1: Time Bank UI
- Display current balance
- Add time manually
- Show total banked time

### T7.2: Task Catalog
- Predefined task list with reward values
- Tap to add reward to balance

---

## Phase 8: Session Management (FR-06)

### T8.1: Session Start
- "Start Reward Time" action
- Remove shields for targets
- Begin monitoring usage
- Show active state, remaining time, start timestamp

### T8.2: Session End
- Detect balance reaches zero
- Auto re-lock through extensions
- Show native block

---

## Phase 9: State Recovery (FR-09)

### T9.1: App Lifecycle Handling
- Restore configuration from App Group
- Restore balance on app launch
- Handle app termination gracefully

### T9.2: Device Restart
- Re-apply shields if session inactive
- Return to correct locked/unlocked state

---

## Phase 10: UI/UX (FR-10, Section 10)

### T10.1: Setup Flow UI
- Authorization request screen
- Target picker screen
- Confirm locked state

### T10.2: Rewards UI
- Task list with values
- Add time button
- Balance display

### T10.3: Session UI
- Start/Stop button
- Countdown display
- Unlock status indicator

### T10.4: Diagnostics UI
- Authorization status
- Selected target count
- Shield state
- Last monitor callback time
- Last auto-lock event
- Authorization limitations warning

---

## Phase 11: Integration & Testing

### T11.1: End-to-End Testing
- Complete lock → earn → unlock → consume → re-lock loop
- Test app relaunch
- Test force quit
- Test device restart

### T11.2: Build Verification
- Verify project builds successfully
- Verify all extensions compile
- Verify entitlements configured

---

## Task Dependencies

```
T1.1 → T1.2
T1.2 → T2.1, T2.2
T2.1, T2.2 → T3.1
T3.1 → T3.2
T2.2 → T4.1
T4.1 → T4.2
T4.2 → T5.1
T5.1 → T5.2
T5.2 → T6.1
T6.1 → T6.2
T2.2 → T7.1
T7.1 → T7.2
T6.2, T7.2 → T8.1
T8.1 → T8.2
T3.2, T4.2, T5.1, T6.2, T8.2 → T9.1
T9.1 → T9.2
T9.2 → T10.1
T10.1 → T10.2
T10.2 → T10.3
T10.3 → T10.4
T10.4 → T11.1
T11.1 → T11.2
```

---

## Functional Requirements Mapping

| Task | FR |
|------|-----|
| T3.1, T3.2 | FR-01 - Authorization |
| T4.1, T4.2 | FR-02 - Restriction Target Selection |
| T5.1 | FR-03 - Default Locked State |
| T7.1 | FR-04 - Time Banking |
| T7.2 | FR-05 - Task Catalog |
| T8.1 | FR-06 - Session Start |
| T6.1, T6.2 | FR-07 - Usage Monitoring |
| T5.1, T6.2, T8.2 | FR-08 - Auto Re-Lock |
| T9.1, T9.2 | FR-09 - State Recovery |
| T10.4 | FR-10 - Explainability |
