import Foundation

// MARK: - ViewModel

@MainActor
@Observable
final class CharacterListViewModel {

    // MARK: - Dependencies

    let service: CharacterService

    // MARK: - State

    private(set) var state: ContentLoadingState = .initial
    private(set) var characters: [DisneyCharacter] = []
    private(set) var totalPages: Int = 0
    var searchText: String = "" {
        didSet { debounceFilter() }
    }

    // MARK: - Pagination

    private var currentPage = 1
    private let pageSize = 20
    private var hasMorePages: Bool {
        currentPage < totalPages
    }

    // MARK: - Local filtering

    private var allFetchedCharacters: [DisneyCharacter] = []
    private var filterTask: Task<Void, Never>?

    // MARK: - Init

    init(service: CharacterService) {
        self.service = service
    }

    // MARK: - Public API

    func initialFetch() async {
        guard state == .initial else { return }
        await fetchFirstPage()
    }

    func refresh() async {
        guard state != .loading else { return }
        state = .refreshing
        currentPage = 1
        await performFetch(page: 1, replacing: true)
    }

    func fetchNextPageIfNeeded(currentItem: DisneyCharacter) async {
        guard hasMorePages,
              state != .loading,
              let lastItem = allFetchedCharacters.last,
              currentItem.id == lastItem.id
        else { return }

        currentPage += 1
        await performFetch(page: currentPage, replacing: false)
    }

    // MARK: - Private

    private func fetchFirstPage() async {
        state = .loading
        currentPage = 1
        await performFetch(page: 1, replacing: true)
    }

    private func performFetch(page: Int, replacing: Bool) async {
        do {
            let response = try await service.fetchCharacters(page: page, pageSize: pageSize)

            totalPages = response.info.totalPages

            if replacing {
                allFetchedCharacters = response.data
            } else {
                allFetchedCharacters += response.data
            }
            filterCharacters()
            state = .loaded
        } catch is CancellationError {
            // Task was cancelled — no state change
        } catch {
            if characters.isEmpty {
                state = .error("Something went wrong. Please try again.")
            } else {
                state = .loaded
            }
        }
    }

    // MARK: - Local Filtering

    private func debounceFilter() {
        filterTask?.cancel()
        filterTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            filterCharacters()
        }
    }

    private func filterCharacters() {
        if searchText.isEmpty {
            characters = allFetchedCharacters
        } else {
            characters = allFetchedCharacters.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
