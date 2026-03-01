import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 10: Networking
// ─────────────────────────────────────────────────────────────
// URLSession.dataTaskPublisher(for:) is Combine's bridge to
// networking. Chain operators to build a complete pipeline:
//
//   dataTaskPublisher → .map(\.data) → .decode → .receive(on:)
//
// .sink(receiveCompletion:receiveValue:) handles both the
// success path and errors in one place.
//
// The ViewModel accepts a PostsFetching protocol so tests can
// inject a mock — a common dependency-injection pattern.
// ─────────────────────────────────────────────────────────────

struct Post: Identifiable, Decodable, Sendable {
    let id: Int
    let title: String
    let body: String
}

// MARK: - Dependency

protocol PostsFetching {
    func fetchPosts() -> AnyPublisher<[Post], any Error>
}

struct LivePostsFetcher: PostsFetching {
    func fetchPosts() -> AnyPublisher<[Post], any Error> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Post].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK: - ViewModel

final class NetworkingViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let fetcher: any PostsFetching
    private var cancellables = Set<AnyCancellable>()

    init(fetcher: any PostsFetching = LivePostsFetcher()) {
        self.fetcher = fetcher
    }

    func fetchPosts() {
        isLoading = true
        errorMessage = nil

        fetcher.fetchPosts()
            .receive(on: DispatchQueue.main) // redundant with @MainActor isolation, but explicit for clarity
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] posts in
                    self?.posts = Array(posts.prefix(20))
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - View

struct Recipe10_Networking: View {
    @StateObject private var vm = NetworkingViewModel()

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView("Fetching posts...")
            } else if let error = vm.errorMessage {
                VStack(spacing: 12) {
                    ContentUnavailableView(error,
                                           systemImage: "exclamationmark.triangle")
                    Button("Retry") { vm.fetchPosts() }
                        .buttonStyle(.bordered)
                }
            } else if vm.posts.isEmpty {
                VStack(spacing: 16) {
                    Text("Tap to fetch posts from\njsonplaceholder.typicode.com")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button("Load Posts") { vm.fetchPosts() }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List(vm.posts) { post in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(post.body)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
        .navigationTitle("Networking")
    }
}

#Preview {
    NavigationStack { Recipe10_Networking() }
}
