// ─────────────────────────────────────────────────────────────
// Testing pattern: Inverted expectation (assert nothing happens)
// ─────────────────────────────────────────────────────────────
// To test that a value is FILTERED OUT, use an inverted
// expectation. If the publisher emits, the test fails.
// If it stays silent through the timeout, the test passes.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import Combine
import XCTest

final class Recipe05_FilterTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testNonEmptyTermIsRecorded() {
        let vm = FilterViewModel()
        let exp = expectation(description: "term recorded")

        vm.$searchHistory
            .dropFirst()
            .first()
            .sink { history in
                XCTAssertEqual(history, ["swift"])
                exp.fulfill()
            }
            .store(in: &cancellables)

        vm.inputText = "Swift"   // pipeline lowercases to "swift"
        wait(for: [exp], timeout: 2)
    }

    func testWhitespaceOnlyIsFilteredOut() {
        let vm = FilterViewModel()

        // Inverted: we expect this NOT to be fulfilled
        let exp = expectation(description: "no term recorded")
        exp.isInverted = true

        vm.$searchHistory
            .dropFirst()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        vm.inputText = "   "     // trimmed to "", then .filter blocks it
        wait(for: [exp], timeout: 1)
        XCTAssertTrue(vm.searchHistory.isEmpty)
    }
}
