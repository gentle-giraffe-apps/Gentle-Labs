import Foundation
import Testing
@testable import PokemonTCG

@Suite("PokemonTCG Tests")
struct PokemonTCGTests {

    @Test("Mock service returns expected page size")
    func mockServiceReturnsExpectedCount() async throws {
        let service = MockCardService(itemsPerPage: 10, totalItems: 25)
        let response = try await service.fetchCards(page: 1, pageSize: 10)
        #expect(response.data.count == 10)
        #expect(response.totalCount == 25)
    }

    @Test("Empty service returns no results")
    func emptyServiceReturnsEmpty() async throws {
        let service = EmptyCardService()
        let response = try await service.fetchCards(page: 1, pageSize: 10)
        #expect(response.data.isEmpty)
    }

    @Test("Failing service throws error")
    func failingServiceThrows() async {
        let service = FailingCardService()
        await #expect(throws: URLError.self) {
            try await service.fetchCards(page: 1, pageSize: 10)
        }
    }

    @Test("ViewModel initial fetch transitions to loaded state")
    @MainActor
    func viewModelInitialFetch() async {
        let viewModel = CardListViewModel(service: MockCardService())
        #expect(viewModel.state == .unloaded)
        await viewModel.initialFetch()
        #expect(viewModel.state == .loaded)
        #expect(viewModel.cards.count == 20)
    }

    @Test("ViewModel handles error state")
    @MainActor
    func viewModelErrorState() async {
        let viewModel = CardListViewModel(service: FailingCardService())
        await viewModel.initialFetch()
        if case .error = viewModel.state {
            // expected
        } else {
            Issue.record("Expected error state")
        }
    }
}
