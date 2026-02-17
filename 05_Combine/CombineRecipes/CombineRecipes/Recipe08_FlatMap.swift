import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 08: FlatMap
// ─────────────────────────────────────────────────────────────
// .flatMap takes each emitted value and returns a NEW publisher.
// The results from those inner publishers are flattened into
// a single output stream.
//
// Use it to chain dependent operations: the user picks a
// category → we start a (simulated) fetch for that category.
//
// Note: if the user switches categories quickly, flatMap keeps
// ALL inner publishers alive. For "cancel previous" behavior,
// use .map { ... }.switchToLatest() instead.
// ─────────────────────────────────────────────────────────────

final class FlatMapViewModel: ObservableObject {
    @Published var selectedCategory = ""
    @Published private(set) var items: [String] = []
    @Published private(set) var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    private let catalog: [String: [String]] = [
        "Fruits":  ["Apple", "Banana", "Cherry", "Mango", "Peach"],
        "Colors":  ["Red", "Blue", "Green", "Yellow", "Purple"],
        "Animals": ["Cat", "Dog", "Bird", "Fish", "Rabbit"],
    ]

    init() {
        $selectedCategory
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .flatMap { [weak self] category -> AnyPublisher<[String], Never> in
                // Simulate a 0.5 s network call
                let results = self?.catalog[category] ?? []
                return Just(results)
                    .delay(for: .seconds(0.5), scheduler: RunLoop.main)
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] results in
                guard let self else { return }
                items = results
                isLoading = false
            }
            .store(in: &cancellables)
    }
}

struct Recipe08_FlatMap: View {
    @StateObject private var vm = FlatMapViewModel()

    private let categories = ["Fruits", "Colors", "Animals"]

    var body: some View {
        VStack(spacing: 20) {
            Picker("Category", selection: $vm.selectedCategory) {
                Text("Pick one").tag("")
                ForEach(categories, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if vm.isLoading {
                ProgressView("Loading...")
                    .frame(maxHeight: .infinity)
            } else if vm.items.isEmpty {
                ContentUnavailableView("Pick a category above",
                                       systemImage: "tray")
            } else {
                List(vm.items, id: \.self) { item in
                    Text(item)
                }
            }
        }
        .navigationTitle("FlatMap")
    }
}

#Preview {
    NavigationStack { Recipe08_FlatMap() }
}
