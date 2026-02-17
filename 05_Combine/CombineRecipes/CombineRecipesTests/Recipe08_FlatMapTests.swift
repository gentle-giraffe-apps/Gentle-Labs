// ─────────────────────────────────────────────────────────────
// Testing pattern: Waiting for an async chain
// ─────────────────────────────────────────────────────────────
// flatMap with a .delay inside means the result arrives
// asynchronously. Subscribe to the output @Published property
// and wait with an expectation.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import Combine
import XCTest

final class Recipe08_FlatMapTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testSelectingCategoryLoadsItems() {
        let vm = FlatMapViewModel()
        let exp = expectation(description: "items loaded")

        vm.$items
            .dropFirst()
            .first { !$0.isEmpty }
            .sink { items in
                XCTAssertEqual(items, ["Apple", "Banana", "Cherry", "Mango", "Peach"])
                exp.fulfill()
            }
            .store(in: &cancellables)

        vm.selectedCategory = "Fruits"
        wait(for: [exp], timeout: 2)
        XCTAssertFalse(vm.isLoading)
    }

    func testChangingCategoryReplacesItems() {
        let vm = FlatMapViewModel()

        // Wait for first category to load
        let firstExp = expectation(description: "first category loaded")
        vm.$items
            .dropFirst()
            .first { !$0.isEmpty }
            .sink { _ in firstExp.fulfill() }
            .store(in: &cancellables)

        vm.selectedCategory = "Fruits"
        wait(for: [firstExp], timeout: 2)

        // Now switch categories
        let secondExp = expectation(description: "second category loaded")
        vm.$items
            .dropFirst()
            .first { $0.contains("Red") }
            .sink { items in
                XCTAssertEqual(items, ["Red", "Blue", "Green", "Yellow", "Purple"])
                secondExp.fulfill()
            }
            .store(in: &cancellables)

        vm.selectedCategory = "Colors"
        wait(for: [secondExp], timeout: 2)
    }
}
