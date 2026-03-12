import XCTest
@testable import RewardShield

final class TimeBankTests: XCTestCase {

    func testAddTime() {
        var timeBank = TimeBank()

        timeBank.addTime(minutes: 30)

        XCTAssertEqual(timeBank.totalBankedSeconds, 1800)
        XCTAssertEqual(timeBank.remainingSeconds, 1800)
        XCTAssertEqual(timeBank.totalBankedMinutes, 30)
        XCTAssertEqual(timeBank.remainingMinutes, 30)
    }

    func testAddTimeMultipleTimes() {
        var timeBank = TimeBank()

        timeBank.addTime(minutes: 15)
        timeBank.addTime(minutes: 30)

        XCTAssertEqual(timeBank.totalBankedSeconds, 2700)
        XCTAssertEqual(timeBank.remainingSeconds, 2700)
    }

    func testConsumeTime() {
        var timeBank = TimeBank()
        timeBank.addTime(minutes: 30)

        timeBank.consumeTime(seconds: 600) // 10 minutes

        XCTAssertEqual(timeBank.remainingSeconds, 1200)
        XCTAssertEqual(timeBank.remainingMinutes, 20)
    }

    func testConsumeTimeExhaustsBalance() {
        var timeBank = TimeBank()
        timeBank.addTime(minutes: 10)

        timeBank.consumeTime(seconds: 700) // More than available

        XCTAssertEqual(timeBank.remainingSeconds, 0)
    }

    func testRemainingMinutes() {
        var timeBank = TimeBank()
        timeBank.addTime(minutes: 45)

        XCTAssertEqual(timeBank.remainingMinutes, 45)
    }

    func testTotalBankedMinutes() {
        var timeBank = TimeBank()
        timeBank.addTime(minutes: 30)
        timeBank.addTime(minutes: 15)

        XCTAssertEqual(timeBank.totalBankedMinutes, 45)
    }
}

final class ActiveSessionTests: XCTestCase {

    func testStartSession() {
        var session = ActiveSession()

        session.start(grantedSeconds: 1800, targetVersion: 1)

        XCTAssertTrue(session.isActive)
        XCTAssertNotNil(session.startedAt)
        XCTAssertEqual(session.grantedSeconds, 1800)
        XCTAssertEqual(session.consumedSeconds, 0)
        XCTAssertEqual(session.targetSelectionVersion, 1)
    }

    func testStopSession() {
        var session = ActiveSession()
        session.start(grantedSeconds: 1800, targetVersion: 1)

        session.stop()

        XCTAssertFalse(session.isActive)
        XCTAssertNil(session.startedAt)
        XCTAssertEqual(session.grantedSeconds, 0)
    }

    func testRemainingSeconds() {
        var session = ActiveSession()
        session.start(grantedSeconds: 1800, targetVersion: 1)

        let remaining = session.remainingSeconds

        XCTAssertGreaterThanOrEqual(remaining, 1799)
        XCTAssertLessThanOrEqual(remaining, 1800)
    }

    func testRemainingSecondsWhenExhausted() {
        var session = ActiveSession()
        session.start(grantedSeconds: 100, targetVersion: 1)
        session.consumedSeconds = 100

        XCTAssertEqual(session.remainingSeconds, 0)
    }

    func testElapsedSeconds() {
        var session = ActiveSession()
        session.start(grantedSeconds: 1800, targetVersion: 1)

        let elapsed = session.elapsedSeconds

        XCTAssertGreaterThanOrEqual(elapsed, 0)
    }
}

final class RewardTaskTests: XCTestCase {

    func testRewardSeconds() {
        let task = RewardTask(title: "Test", rewardMinutes: 30)

        XCTAssertEqual(task.rewardSeconds, 1800)
    }

    func testDefaultEnabled() {
        let task = RewardTask(title: "Test", rewardMinutes: 15)

        XCTAssertTrue(task.isEnabled)
    }

    func testCustomEnabled() {
        let task = RewardTask(title: "Test", rewardMinutes: 15, isEnabled: false)

        XCTAssertFalse(task.isEnabled)
    }
}

final class EnforcementStateTests: XCTestCase {

    func testApplyShield() {
        var state = EnforcementState()

        state.applyShield()

        XCTAssertTrue(state.shieldApplied)
        XCTAssertNotNil(state.lastShieldAppliedAt)
    }

    func testRemoveShield() {
        var state = EnforcementState()
        state.applyShield()

        state.removeShield()

        XCTAssertFalse(state.shieldApplied)
        XCTAssertNotNil(state.lastShieldRemovedAt)
    }

    func testRecordError() {
        var state = EnforcementState()

        state.recordError("Test error")

        XCTAssertEqual(state.lastError, "Test error")
    }
}
