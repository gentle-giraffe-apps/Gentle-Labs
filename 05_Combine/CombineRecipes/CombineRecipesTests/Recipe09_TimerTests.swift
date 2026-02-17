// ─────────────────────────────────────────────────────────────
// Testing pattern: State management + real timer
// ─────────────────────────────────────────────────────────────
// For start/stop/reset, test the state transitions synchronously.
// For verifying the timer actually ticks, use a short real wait.
// In production apps you'd inject a Clock — here we keep it
// simple to show the basic pattern.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import XCTest

final class Recipe09_TimerTests: XCTestCase {

    func testStartSetsRunning() {
        let vm = StopwatchViewModel()
        XCTAssertFalse(vm.isRunning)
        vm.start()
        XCTAssertTrue(vm.isRunning)
    }

    func testStopClearsRunning() {
        let vm = StopwatchViewModel()
        vm.start()
        vm.stop()
        XCTAssertFalse(vm.isRunning)
    }

    func testResetClearsEverything() {
        let vm = StopwatchViewModel()
        vm.start()

        // Wait for at least one tick
        let exp = expectation(description: "timer ticks")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
        XCTAssertGreaterThan(vm.secondsElapsed, 0)

        vm.reset()
        XCTAssertEqual(vm.secondsElapsed, 0)
        XCTAssertFalse(vm.isRunning)
    }

    func testStopPreventsFurtherTicks() {
        let vm = StopwatchViewModel()
        vm.start()
        vm.stop()
        let countAfterStop = vm.secondsElapsed

        let exp = expectation(description: "wait to confirm no ticks")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)

        XCTAssertEqual(vm.secondsElapsed, countAfterStop)
    }
}
