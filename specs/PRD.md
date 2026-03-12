# PRD — Reward Shield POC

## 1. Executive Summary

**Project Name:** Reward Shield POC

**Objective:**  
Validate whether an iOS app can use Apple’s Screen Time APIs to implement a **time-as-currency** model on a single device: selected apps or app categories are blocked by default, time is earned through completed tasks, and access is restored temporarily until the earned balance is consumed, after which system shields are re-applied automatically.

**POC Goal:**  
Prove the core loop works end to end:

1. Parent/admin configures restricted targets and reward values.
2. Child/user earns time by completing tasks.
3. User starts a session.
4. Selected apps/categories become accessible.
5. Usage is monitored in the background.
6. Shields return automatically when the balance is exhausted.

**POC Non-Goals:**  
This phase does not aim to solve cross-device parent management, chore verification workflows, anti-tamper hardening beyond what iOS allows, billing, notifications polish, or production-grade analytics.

---

## 2. Problem Statement

Parents want a lightweight reward mechanism that turns screen access into something earned rather than always available. The desired behavior is:

- specific distracting apps/categories start locked,
- time can be granted in controlled increments,
- unlocked access lasts only for the earned duration,
- locking resumes automatically without manual intervention.

The POC exists to determine how closely iOS Screen Time APIs can support this experience natively, and where platform constraints require product compromises.

---

## 3. Product Hypothesis

If the app uses Apple’s Screen Time stack correctly, then it should be possible to deliver a working “earn time, then spend time” flow with native shields and background enforcement on the same iPhone or iPad. The main open questions are reliability, enforcement timing, platform limitations, and tamper resistance under individual authorization.

---

## 4. Users and Roles

### Administrator
Typically a parent or guardian configuring the experience on the device.

Needs:
- choose what is restricted,
- define how much time a task earns,
- grant time quickly,
- trust that restrictions come back automatically,
- understand where the system is reliable versus bypassable.

### User
Typically a child using the device.

Needs:
- see current balance,
- understand what can be unlocked,
- start a reward session easily,
- get clear feedback when time ends.

---

## 5. User Stories

### Administrator Stories

- As an administrator, I want to choose which apps, categories, or web domains are restricted by default.
- As an administrator, I want to assign reward values to tasks so that completed tasks convert into banked time.
- As an administrator, I want the app to restore restrictions automatically when time runs out.
- As an administrator, I want the POC to clearly show which behaviors are enforced by iOS and which can still be disabled by the device owner.

### User Stories

- As a user, I want to see my current time balance.
- As a user, I want to start a reward session when I am ready to use my earned time.
- As a user, I want a native shield or equivalent system block when I run out of time.
- As a user, I want the experience to feel predictable and fair.

---

## 6. POC Scope

### In Scope

- Individual authorization using Apple Screen Time APIs on-device.
- Restriction target selection using `FamilyActivityPicker`.
- Persistent shields using `ManagedSettings`.
- Shared state via App Group.
- Time banking UI.
- Session start/stop flow.
- Usage monitoring with `DeviceActivity`.
- Automatic re-lock when balance is exhausted.

### Out of Scope

- Managing another family member’s Screen Time remotely from a separate parent device.
- Writing directly into Apple’s built-in Screen Time settings UI.
- Strong anti-removal or anti-disable protections under individual authorization.
- Server backend.
- Multi-child account management.
- OCR, photo proof, or approval workflows for chores.
- App Store launch readiness.

---

## 7. Key Platform Constraints

The POC must be built around platform reality, not assumed parental-control powers.

### Constraint A — No direct editing of Apple’s Screen Time settings UI
The app should treat Apple’s Screen Time UI as separate system UI. The goal is to recreate the behavior through APIs, not programmatically modify the built-in App Limits screens.

### Constraint B — Individual authorization is weaker than child-account parental authorization
Individual authorization enables Screen Time API use for independent users on their own devices, but it does not include the stronger anti-tamper protections associated with child-account parental controls.

### Constraint C — Restriction targets are represented by opaque tokens
Selections from `FamilyActivityPicker` should be stored as opaque tokens rather than treated like normal app identifiers.

### Constraint D — Background enforcement is extension-driven
The host app cannot be assumed to stay alive. Enforcement must rely on Screen Time extensions and shared data, not foreground app state.

### Constraint E — Timing may not be perfectly exact
For a POC, enforcement should be considered successful if re-locking occurs within an acceptable delay window rather than at the exact second the balance reaches zero.

---

## 8. Functional Requirements

### FR-01 — Authorization
The app must request and store Screen Time authorization using individual authorization on the same device.  
**Acceptance:** authorization state is surfaced in the UI, and the app blocks POC flows until authorization is granted.

### FR-02 — Restriction Target Selection
The app must allow the administrator to select restricted apps, categories, and optionally websites using Apple’s picker.  
**Acceptance:** the selection persists across launches and can be edited.

### FR-03 — Default Locked State
The app must apply shields to all configured targets by default.  
**Acceptance:** after initial configuration, selected targets are blocked unless a reward session is active.

### FR-04 — Time Banking
The app must maintain a banked time balance in minutes.  
**Acceptance:** the administrator can add time manually through the POC UI, and the balance persists across app restarts.

### FR-05 — Task Catalog
The app must support a simple list of predefined tasks with reward values.  
**Acceptance:** tapping a task adds its configured reward amount to the balance.

### FR-06 — Session Start
The app must provide a “Start Reward Time” action that removes shields for configured targets and begins monitoring usage consumption.  
**Acceptance:** when a session starts, the UI shows active state, remaining time, and start timestamp.

### FR-07 — Usage Monitoring
The system must monitor usage of the selected targets while a reward session is active.  
**Acceptance:** monitored time counts down against the earned balance.

### FR-08 — Auto Re-Lock
When the balance reaches zero, the app must automatically restore shields through background-capable Screen Time components.  
**Acceptance:** access to selected targets is blocked again without opening the app.

### FR-09 — State Recovery
The system must recover gracefully after app termination or device restart.  
**Acceptance:** stored configuration and balance are restored from shared storage, and the app returns to the correct locked/unlocked state as closely as platform behavior allows.

### FR-10 — Explainability
The app must expose system status in plain language.  
**Acceptance:** the UI can show:
- authorized / not authorized,
- targets selected / not selected,
- shield active / inactive,
- session active / inactive,
- remaining time,
- last enforcement event.

---

## 9. Non-Functional Requirements

### NFR-01 — Reliability
The POC should successfully re-apply restrictions in the vast majority of normal test runs.

### NFR-02 — Persistence
Configuration and time balance must survive app relaunch and expected device lifecycle events.

### NFR-03 — Native Feel
Where possible, use Apple-provided picker and shield experiences instead of custom clones.

### NFR-04 — Minimal Architecture
The POC should avoid unnecessary backend services and run fully on-device.

### NFR-05 — Transparency About Tamper Limits
The product must not claim strong parental tamper resistance under individual authorization.

---

## 10. UX Requirements

### 10.1 Setup
- Request authorization
- Pick restricted targets
- Confirm default lock state

### 10.2 Rewards
- List of tasks and reward values
- Add time manually
- Show total banked time

### 10.3 Session
- Start reward time
- Show countdown / remaining balance
- Show whether apps are currently unlocked

### 10.4 Status / Debug
- Authorization status
- Selected target count
- Current shield state
- Last monitor callback time
- Last auto-lock event
- Warnings about individual-authorization limitations

---

## 11. Technical Architecture

### Host App
Responsibilities:
- authorization request,
- admin UI,
- reward banking UI,
- session initiation,
- diagnostics display,
- persistence orchestration.

### Managed Settings Store
Responsibilities:
- apply and remove shields for configured targets.

### Device Activity Monitor Extension
Responsibilities:
- monitor usage during active sessions,
- detect balance exhaustion,
- trigger re-lock behavior in the background.

### Managed Settings UI / Shield Experience
Responsibilities:
- present native restriction experience where applicable.

### App Group Shared Storage
Responsibilities:
- store selected tokens,
- store banked time,
- store active-session metadata,
- store last-known enforcement state.

### Suggested Data Model

#### SelectedTargets
- application tokens
- category tokens
- web domain tokens

#### RewardTask
- id
- title
- rewardMinutes
- enabled

#### TimeBank
- totalBankedSeconds
- remainingSeconds
- lastUpdatedAt

#### ActiveSession
- isActive
- startedAt
- grantedSeconds
- consumedSeconds
- targetSelectionVersion

#### EnforcementState
- shieldApplied
- lastShieldAppliedAt
- lastShieldRemovedAt
- lastMonitorEventAt
- lastError

---

## 12. POC Workflow

### Setup Flow
1. Install app.
2. Request Screen Time authorization.
3. Choose restricted targets in picker.
4. Apply shields immediately.
5. Confirm blocked state.

### Reward Flow
1. Admin selects a task such as “Homework”.
2. Tapping the task adds minutes to the balance.
3. Updated balance is shown immediately.

### Usage Flow
1. User taps “Start Reward Time”.
2. Shields are removed for selected targets.
3. Monitoring begins.
4. Remaining balance decreases as monitored usage occurs.
5. When balance reaches zero, monitor extension re-applies shields.
6. User sees native block again.

---

## 13. Success Criteria

### Primary Success Criteria

#### SC-01 — End-to-End Loop Works
The app can complete the full cycle from locked state to earned time to unlocked access to auto re-lock.

#### SC-02 — Restrictions Survive Normal App Lifecycle
The POC continues to function after app termination and relaunch.

#### SC-03 — Enforcement Works in Background
Auto re-lock occurs without requiring the host app to be foregrounded.

#### SC-04 — Acceptable Timing
Restrictions are restored within a practical tolerance window after balance exhaustion.

#### SC-05 — Clear Constraints Identified
The POC produces a documented list of what works, what is flaky, and what is impossible or unsafe to promise under individual authorization.

### Suggested Quantitative Targets

- **Authorization success:** at least 90% of clean install test runs.
- **Auto re-lock success:** at least 90% of test sessions.
- **Re-lock timing:** typically within 60 seconds of exhausted balance.
- **Recovery after relaunch:** state restored in 100% of normal app relaunch tests.
- **Recovery after reboot:** configuration restored and shields re-applied if session is inactive in most test cases.

---

## 14. Risks and Unknowns

### Risk 1 — User can disable the app’s authority
Under individual authorization, the device owner may be able to revoke or disable the app’s restrictions from Settings, which weakens parental-control positioning.

### Risk 2 — Background timing is imperfect
Monitor callbacks may not fire exactly when expected in all cases.

### Risk 3 — Token handling is awkward
Selections are privacy-preserving opaque tokens, which can complicate display, syncing, and debugging.

### Risk 4 — Entitlement / review constraints
Screen Time API usage may involve Apple entitlements and review requirements that affect production viability, even if the POC works technically.

### Risk 5 — Production expectations may exceed platform reality
A strong “tamper-proof parental controls” promise may not be supportable for a same-device, individually authorized design.

---

## 15. Assumptions

- The POC is built for iPhone first.
- The app runs on a modern iOS version that supports Screen Time individual authorization and current Screen Time frameworks.
- The same physical device is used for setup and enforcement.
- Rewards are granted manually in-app for the POC.
- No backend is required.

---

## 16. Open Questions for the POC

1. How consistently does auto re-lock occur in real-world testing?
2. Does app/device restart ever leave targets briefly accessible?
3. What happens if the user starts a session, then force-quits the app?
4. What happens if the user changes time, locale, or Screen Time settings?
5. Can balance consumption be limited only to selected targets in a way that feels fair?
6. What exact UX should be shown when authorization is revoked?
7. Is same-device individual authorization acceptable for the intended use case, or is family/child-account architecture required for a real product?

---

## 17. Recommended POC Deliverables

- Working iOS app with:
  - authorization flow,
  - target selection,
  - default shielding,
  - reward banking,
  - session start,
  - automatic re-lock.
- Test matrix covering:
  - app relaunch,
  - force quit,
  - reboot,
  - low battery mode,
  - authorization revoked,
  - target set changes,
  - multiple short sessions.
- Findings report documenting:
  - what is technically possible,
  - where timing or reliability breaks,
  - where Apple platform constraints prevent a stronger product claim.

---

## 18. Final Product Framing for the POC

This POC should be framed as a feasibility study for a native iOS reward-based access controller using Screen Time APIs, not yet as a fully tamper-proof parental-control product. The technical thesis is strong enough to justify a prototype because Apple provides the necessary building blocks—authorization, selection, shielding, and device activity monitoring—but the final viability depends on how acceptable the platform’s enforcement and tamper limitations are in practice.
