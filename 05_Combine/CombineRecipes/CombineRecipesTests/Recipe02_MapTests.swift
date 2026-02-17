// ─────────────────────────────────────────────────────────────
// Testing pattern: Synchronous assertion
// ─────────────────────────────────────────────────────────────
// Combine pipelines with no scheduler (no debounce, delay, or
// receive(on:)) fire synchronously. Set a @Published input,
// then assert the output on the very next line.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import XCTest

final class Recipe02_MapTests: XCTestCase {

    func testEmptyNameShowsPlaceholder() {
        let vm = MapViewModel()
        XCTAssertEqual(vm.greeting, "Type your name below")
        XCTAssertEqual(vm.characterCount, 0)
    }

    func testNameUpdatesGreetingAndCount() {
        let vm = MapViewModel()
        vm.name = "Alice"
        XCTAssertEqual(vm.greeting, "Hello, Alice!")
        XCTAssertEqual(vm.characterCount, 5)
    }

    func testClearingNameRestoresPlaceholder() {
        let vm = MapViewModel()
        vm.name = "Bob"
        vm.name = ""
        XCTAssertEqual(vm.greeting, "Type your name below")
        XCTAssertEqual(vm.characterCount, 0)
    }
}
