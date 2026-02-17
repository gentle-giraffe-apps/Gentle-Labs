import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 08: Chaining (replaces flatMap)
// ─────────────────────────────────────────────────────────────
// Combine equivalent: $category.flatMap { ... publisher ... }.sink
//
// With async/await, sequential operations are just... sequential.
// No flatMap, no publisher chain, no eraseToAnyPublisher.
//
// .task(id:) is the key SwiftUI integration: it cancels the
// previous task and starts a new one whenever the id changes.
// This replaces both flatMap AND switchToLatest in one modifier.
// ─────────────────────────────────────────────────────────────

@Observable
class ChainingViewModel {
    var selectedCategory = ""
    private(set) var items: [String] = []
    private(set) var isLoading = false

    private let catalog: [String: [String]] = [
        "Fruits":  ["Apple", "Banana", "Cherry", "Mango", "Peach"],
        "Colors":  ["Red", "Blue", "Green", "Yellow", "Purple"],
        "Animals": ["Cat", "Dog", "Bird", "Fish", "Rabbit"],
    ]

    func loadItems(for category: String) async {
        isLoading = true
        try? await Task.sleep(for: .seconds(0.5))  // simulate network
        items = catalog[category] ?? []
        isLoading = false
    }
}

struct Recipe08_Chaining: View {
    @State private var vm = ChainingViewModel()

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
        .navigationTitle("Chaining")
        // .task(id:) cancels the old task and starts a new one
        // when selectedCategory changes — like switchToLatest
        .task(id: vm.selectedCategory) {
            guard !vm.selectedCategory.isEmpty else { return }
            await vm.loadItems(for: vm.selectedCategory)
        }
    }
}

#Preview {
    NavigationStack { Recipe08_Chaining() }
}
