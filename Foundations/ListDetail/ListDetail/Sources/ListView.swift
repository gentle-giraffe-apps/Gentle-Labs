import Observation
import SwiftUI

// MARK: - Model
struct UserModel: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let email: String
    let avatarURL: URL
}

struct PaginatedPage<Item: Decodable & Sendable>: Decodable, Sendable {
    let items: [Item]
    let page: Int
    let perPage: Int
    let total: Int
    let totalPages: Int

    var hasMore: Bool { page < totalPages }
    var nextPage: Int? { hasMore ? (page + 1) : nil }

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case items = "data"  // The API calls the array "data"
    }
}

// MARK: - Service
protocol UserService: Sendable {
    func fetchUsers(page: Int) async throws -> PaginatedPage<UserModel>
}

// MARK: - Mock Service
struct MockUserService: UserService, Sendable {

    // Tune these once; everything else derives from them
    private let totalUsers = 12
    private let perPage = 6

    func fetchUsers(page: Int) async throws -> PaginatedPage<UserModel> {
        // Simulate network latency (nice for UI testing)
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s

        let totalPages = Int(ceil(Double(totalUsers) / Double(perPage)))
        guard page >= 1, page <= totalPages else {
            // Empty page beyond bounds (matches many real APIs)
            return PaginatedPage(
                items: [],
                page: page,
                perPage: perPage,
                total: totalUsers,
                totalPages: totalPages
            )
        }

        let startIndex = (page - 1) * perPage
        let endIndex = min(startIndex + perPage, totalUsers)

        let items = (startIndex..<endIndex).map { index in
            UserModel(
                id: index + 1,
                name: "User \(index + 1)",
                email: "user\(index + 1)@example.com",
                avatarURL: URL(string: "https://reqres.in/img/faces/\(index + 1)-image.jpg")!
            )
        }

        return PaginatedPage(
            items: items,
            page: page,
            perPage: perPage,
            total: totalUsers,
            totalPages: totalPages
        )
    }
}

enum ContentLoadingState: Equatable {
    case idle          // not currently loading
    case loading       // currently fetching (initial or next page)
    case empty         // loaded successfully but no items
    case error(String) // last request failed
}

@MainActor
@Observable
final class ListViewModel {
    let service: UserService
    var state: ContentLoadingState = .idle
    var items: [UserModel] = []

    private var nextPage = 1
    private var hasMore = true
    private var isLoading = false

    /// Read-only exposure for the View (no setter).
    var canLoadMore: Bool { hasMore }
    
    init(service: UserService) { self.service = service }

    func loadInitialIfNeeded() async {
        guard state == .idle, items.isEmpty else { return }
        await refresh()
    }

    func refresh() async {
        items = []
        nextPage = 1
        hasMore = true
        state = .loading
        await loadNextPage()
    }

    func loadNextPage() async {
        guard hasMore, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await service.fetchUsers(page: nextPage)
            items.append(contentsOf: page.items)
            hasMore = page.hasMore
            nextPage += 1

            state = items.isEmpty ? .empty : .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func retry() async {
        if items.isEmpty { state = .loading }
        await loadNextPage()
    }
}

// MARK: - View

struct ListView: View {
    @State private var viewModel = ListViewModel(service: MockUserService())
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    if viewModel.items.isEmpty {
                        ProgressView("Idle...")
                    } else {
                        List {
                            ForEach(viewModel.items) { item in
                                Text(item.name)
                            }
                        }
                        // Footer sentinel: when it appears, load the next page
                        if viewModel.canLoadMore {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .onAppear {
                                    Task { await viewModel.loadNextPage() }
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    Text("End")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            }
                    }
                case .loading:
                    ProgressView("Loading...")
                case .empty:
                    ContentUnavailableView("No data yet", systemImage: "tray")
                case .error(let errorMessage):
                    VStack(spacing: 12) {
                        ContentUnavailableView(errorMessage, systemImage: "exclamationmark.triangle")
                        Button("Retry") {
                            Task { await viewModel.retry() }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ListView()
}
