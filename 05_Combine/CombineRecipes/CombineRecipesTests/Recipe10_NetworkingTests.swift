// ─────────────────────────────────────────────────────────────
// Testing pattern: Dependency injection with mocks
// ─────────────────────────────────────────────────────────────
// NetworkingViewModel accepts a PostsFetching protocol.
// In tests, inject a mock that returns canned data or errors
// instantly — no real network needed.
//
// Even though the mock completes immediately, .receive(on:)
// in the ViewModel dispatches async to the main queue, so
// we still need a brief expectation wait.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import Combine
import XCTest

// MARK: - Test doubles

private struct MockPostsFetcher: PostsFetching {
    let posts: [Post]

    func fetchPosts() -> AnyPublisher<[Post], any Error> {
        Just(posts)
            .setFailureType(to: (any Error).self)
            .eraseToAnyPublisher()
    }
}

private struct FailingPostsFetcher: PostsFetching {
    func fetchPosts() -> AnyPublisher<[Post], any Error> {
        Fail(error: URLError(.badServerResponse))
            .eraseToAnyPublisher()
    }
}

// MARK: - Tests

final class Recipe10_NetworkingTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testSuccessfulFetchPopulatesPosts() {
        let fakePosts = [
            Post(id: 1, title: "First", body: "Body 1"),
            Post(id: 2, title: "Second", body: "Body 2"),
        ]
        let vm = NetworkingViewModel(fetcher: MockPostsFetcher(posts: fakePosts))
        let exp = expectation(description: "posts loaded")

        vm.$posts
            .dropFirst()
            .first { !$0.isEmpty }
            .sink { posts in
                XCTAssertEqual(posts.count, 2)
                XCTAssertEqual(posts.first?.title, "First")
                exp.fulfill()
            }
            .store(in: &cancellables)

        vm.fetchPosts()
        wait(for: [exp], timeout: 2)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func testFailedFetchSetsErrorMessage() {
        let vm = NetworkingViewModel(fetcher: FailingPostsFetcher())
        let exp = expectation(description: "error set")

        vm.$errorMessage
            .dropFirst()
            .first { $0 != nil }
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        vm.fetchPosts()
        wait(for: [exp], timeout: 2)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.posts.isEmpty)
    }
}
