import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 10: Networking
// ─────────────────────────────────────────────────────────────
// Combine equivalent:
//   URLSession.dataTaskPublisher(for:)
//       .map(\.data)
//       .decode(type:decoder:)
//       .receive(on: DispatchQueue.main)
//       .sink(receiveCompletion:receiveValue:)
//       .store(in: &cancellables)
//
// With async/await:
//   let (data, _) = try await URLSession.shared.data(from: url)
//   let posts = try JSONDecoder().decode([Post].self, from: data)
//
// That's it. No publisher chain. No cancellable. No receive(on:).
// Error handling is just try/catch.
// ─────────────────────────────────────────────────────────────

struct Post: Identifiable, Decodable, Sendable {
    let id: Int
    let title: String
    let body: String
}

@Observable
class NetworkingViewModel {
    private(set) var posts: [Post] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    func fetchPosts() async {
        isLoading = true
        errorMessage = nil

        do {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let allPosts = try JSONDecoder().decode([Post].self, from: data)
            posts = Array(allPosts.prefix(20))
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct Recipe10_Networking: View {
    @State private var vm = NetworkingViewModel()

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView("Fetching posts...")
            } else if let error = vm.errorMessage {
                VStack(spacing: 12) {
                    ContentUnavailableView(error,
                                           systemImage: "exclamationmark.triangle")
                    Button("Retry") { Task { await vm.fetchPosts() } }
                        .buttonStyle(.bordered)
                }
            } else if vm.posts.isEmpty {
                VStack(spacing: 16) {
                    Text("Tap to fetch posts from\njsonplaceholder.typicode.com")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button("Load Posts") { Task { await vm.fetchPosts() } }
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
