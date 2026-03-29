import Foundation
import Testing
@testable import DisneyCharacters

@Suite("DisneyCharacters Tests")
@MainActor
struct DisneyCharactersTests {

    @Test("Mock service returns expected page size")
    func mockServiceReturnsExpectedCount() async throws {
        let service = MockCharacterService(itemsPerPage: 10, totalItems: 25)
        let response = try await service.fetchCharacters(page: 1, pageSize: 10)
        #expect(response.data.count == 10)
        #expect(response.info.count == 25)
    }

    @Test("Empty service returns no results")
    func emptyServiceReturnsEmpty() async throws {
        let service = EmptyCharacterService()
        let response = try await service.fetchCharacters(page: 1, pageSize: 10)
        #expect(response.data.isEmpty)
    }

    @Test("Failing service throws error")
    func failingServiceThrows() async {
        let service = FailingCharacterService()
        await #expect(throws: URLError.self) {
            try await service.fetchCharacters(page: 1, pageSize: 10)
        }
    }

    @Test("ViewModel initial fetch transitions to loaded state")
    func viewModelInitialFetch() async {
        let viewModel = CharacterListViewModel(service: MockCharacterService())
        #expect(viewModel.state == .initial)
        await viewModel.initialFetch()
        #expect(viewModel.state == .loaded)
        #expect(viewModel.characters.count == 20)
    }

    @Test("ViewModel handles error state")
    func viewModelErrorState() async {
        let viewModel = CharacterListViewModel(service: FailingCharacterService())
        await viewModel.initialFetch()
        if case .error = viewModel.state {
            // expected
        } else {
            Issue.record("Expected error state")
        }
    }
}
