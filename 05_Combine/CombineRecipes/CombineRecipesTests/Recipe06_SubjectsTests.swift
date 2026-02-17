// ─────────────────────────────────────────────────────────────
// Testing pattern: Subject-driven input
// ─────────────────────────────────────────────────────────────
// Send values through a Subject and assert the ViewModel
// reacts correctly. No timing involved — subjects emit
// synchronously to their subscribers.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import XCTest

final class Recipe06_SubjectsTests: XCTestCase {

    func testPassthroughSubjectAppendsTapLog() {
        let vm = SubjectsViewModel()
        XCTAssertTrue(vm.tapLog.isEmpty)

        vm.tap.send("Hello")
        vm.tap.send("World")

        XCTAssertEqual(vm.tapLog, ["Hello", "World"])
    }

    func testCurrentValueSubjectUpdatesToggleState() {
        let vm = SubjectsViewModel()
        XCTAssertFalse(vm.toggleState)

        vm.toggle.send(true)
        XCTAssertTrue(vm.toggleState)

        vm.toggle.send(false)
        XCTAssertFalse(vm.toggleState)
    }
}
