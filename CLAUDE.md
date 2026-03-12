# CLAUDE.md

## Project
Reward Shield is an iOS proof of concept for a "time-as-currency" screen time app using Apple's Screen Time frameworks.

Core idea:
- selected apps/categories are blocked by default
- time is earned through tasks
- starting a session temporarily unlocks access
- access is re-blocked automatically when earned time is exhausted

## Goal
Build a realistic POC that proves what is technically possible on iOS, especially:
- `FamilyControls` authorization and target selection
- `ManagedSettings` shields
- `DeviceActivity` monitoring
- background re-locking
- persistence via App Groups

## Important Constraints
Treat this as a feasibility-first project, not a production parental-control app.

Assume:
- individual authorization, on-device
- no direct modification of Apple's built-in Screen Time UI
- limited tamper resistance
- extension-driven enforcement
- some timing inexactness in background callbacks

Do not design features that depend on:
- remote parent control of another family member's device
- private entitlements we do not have
- backend services unless explicitly requested
- "perfect" anti-bypass guarantees

## Priorities
1. Make the core lock → earn → unlock → consume → re-lock loop work.
2. Keep the architecture simple and observable.
3. Prefer native Apple APIs and system UI over custom abstractions.
4. Surface platform limitations clearly in code comments and docs.
5. Optimize for testability and clarity over polish.

## Code Preferences
- Swift + SwiftUI
- small focused types
- avoid premature abstraction
- prefer explicit state models
- keep Screen Time logic isolated from UI
- use App Group shared storage for cross-process state
- log important lifecycle and enforcement events

## Suggested Structure
- host app: UI, reward banking, session control
- shared module: models, storage, state transitions
- monitor extension: usage monitoring and re-lock logic
- shield/UI extension: native restriction presentation
- docs: notes on platform constraints and findings

## What Claude Should Do
When helping on this repo:
- favor the smallest working implementation
- call out Apple platform limitations early
- distinguish proven behavior from assumptions
- keep code practical for a POC
- propose instrumentation and test scenarios where useful
- avoid inventing unsupported API capabilities

## What Good Looks Like
A working prototype where:
- targets can be selected
- shields apply by default
- time can be banked
- a reward session can start
- usage is tracked
- shields return automatically when time runs out
- behavior is debuggable and documented
