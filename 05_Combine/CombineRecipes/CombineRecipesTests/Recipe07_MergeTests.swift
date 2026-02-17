// ─────────────────────────────────────────────────────────────
// Testing pattern: Multiple sources, single output
// ─────────────────────────────────────────────────────────────
// Send values from different subjects and verify they all
// arrive in the merged events list in the correct order.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import XCTest

final class Recipe07_MergeTests: XCTestCase {

    func testAllSourcesAppearInOrder() {
        let vm = MergeViewModel()

        vm.buttonA.send()
        vm.buttonB.send()
        vm.buttonC.send()
        vm.buttonA.send()

        XCTAssertEqual(vm.events, [
            "[A] tapped",
            "[B] tapped",
            "[C] tapped",
            "[A] tapped",
        ])
    }

    func testClearRemovesAllEvents() {
        let vm = MergeViewModel()
        vm.buttonA.send()
        vm.buttonB.send()
        XCTAssertEqual(vm.events.count, 2)

        vm.clear()
        XCTAssertTrue(vm.events.isEmpty)
    }
}
