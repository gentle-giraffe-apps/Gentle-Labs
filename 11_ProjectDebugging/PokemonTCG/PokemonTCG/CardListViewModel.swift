import Foundation

// MARK: - ViewModel

@MainActor
@Observable
final class CardListViewModel {

    // MARK: - Dependencies

    let service: CardService

    // MARK: - State

    private(set) var state: ContentLoadingState = .unloaded
    private(set) var cards: [Card] = []
    private(set) var totalCount: Int = 0
    var searchText: String = "" {
        didSet { filterCards() }
    }

    // MARK: - Pagination

    private var currentPage = 1
    private let pageSize = 20
    private var hasMorePages: Bool {
        allFetchedCards.count < totalCount
    }

    // MARK: - Local filtering

    private var allFetchedCards: [Card] = []

    // MARK: - Init

    init(service: CardService) {
        self.service = service
    }

    // MARK: - Public API

    func initialFetch() async {
        guard state == .unloaded else { return }
        await fetchFirstPage()
    }

    func refresh() async {
        guard state != .loading else { return }
        state = .refreshing
        currentPage = 1
        await performFetch(page: 1, replacing: true)
    }

    func fetchNextPageIfNeeded(currentItem: Card) async {
        guard hasMorePages,
              state != .loading,
              let lastItem = allFetchedCards.last,
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
            let response = try await service.fetchCards(page: page, pageSize: pageSize)

            totalCount = response.totalCount

            if replacing {
                allFetchedCards = response.data
            } else {
                allFetchedCards += response.data
            }
            filterCards()
            state = .loaded
        } catch is CancellationError {
            // Task was cancelled — no state change
        } catch {
            if cards.isEmpty {
                state = .error("Something went wrong. Please try again.")
            }
        }
    }

    // MARK: - Local Filtering

    private func filterCards() {
        if searchText.isEmpty {
            cards = allFetchedCards
        } else {
            cards = allFetchedCards.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
