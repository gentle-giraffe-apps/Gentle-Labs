// ─────────────────────────────────────────────────────────────
// Testing pattern: XCTestExpectation for time-delayed publishers
// ─────────────────────────────────────────────────────────────
// .debounce delays emission. You can't assert synchronously.
// Instead, subscribe to the output, fulfill an expectation
// when it arrives, and use wait(for:timeout:).
//
// XCTest's wait() spins the RunLoop, so RunLoop.main-scheduled
// Combine operators (debounce, delay) fire during the wait.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import Combine
import XCTest

final class Recipe03_DebounceTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testDebouncedTextUpdatesAfterDelay() {
        let vm = DebounceViewModel()
        let exp = expectation(description: "debounced text updates")

        vm.$debouncedText
            .dropFirst()   // skip the initial empty value
            .first()       // complete after one emission
            .sink { text in
                XCTAssertEqual(text, "swift")
                exp.fulfill()
            }
            .store(in: &cancellables)

        vm.searchText = "swift"
        wait(for: [exp], timeout: 2)
        XCTAssertEqual(vm.searchCount, 1)
    }

    func testRapidTypingOnlyEmitsFinalValue() {
        let vm = DebounceViewModel()
        let exp = expectation(description: "only final value emitted")

        vm.$debouncedText
            .dropFirst()
            .first()
            .sink { text in
                XCTAssertEqual(text, "combine")
                exp.fulfill()
            }
            .store(in: &cancellables)

        // Simulate rapid typing — debounce resets on each keystroke,
        // so only the final value survives the 0.5 s pause.
        vm.searchText = "c"
        vm.searchText = "co"
        vm.searchText = "com"
        vm.searchText = "comb"
        vm.searchText = "combi"
        vm.searchText = "combin"
        vm.searchText = "combine"

        wait(for: [exp], timeout: 2)
        XCTAssertEqual(vm.searchCount, 1)
    }
}
