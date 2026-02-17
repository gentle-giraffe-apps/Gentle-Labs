import AsyncAlgorithms
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 05: Filter & RemoveDuplicates
// ─────────────────────────────────────────────────────────────
// Combine equivalent: .filter { }.removeDuplicates().sink
//
// .filter is built into AsyncSequence (no import needed).
// .removeDuplicates comes from AsyncAlgorithms.
//
// Chain them just like Combine — the only difference is
// for-await instead of .sink at the end.
// ─────────────────────────────────────────────────────────────

@Observable
class FilterViewModel {
    var inputText = "" {
        didSet { continuation?.yield(inputText) }
    }
    private(set) var searchHistory: [String] = []

    private var continuation: AsyncStream<String>.Continuation?

    func startObserving() async {
        let stream = AsyncStream<String> { continuation in
            self.continuation = continuation
        }

        for await term in stream
            .debounce(for: .seconds(0.4))
            .map({ $0.trimmingCharacters(in: .whitespaces).lowercased() })
            .filter({ !$0.isEmpty })
            .removeDuplicates()
        {
            searchHistory.append(term)
        }
    }

    func clearHistory() { searchHistory.removeAll() }
}

struct Recipe05_Filter: View {
    @State private var vm = FilterViewModel()

    var body: some View {
        VStack(spacing: 16) {
            TextField("Type something...", text: $vm.inputText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            HStack {
                Text("Search History").font(.headline)
                Spacer()
                if !vm.searchHistory.isEmpty {
                    Button("Clear") { vm.clearHistory() }
                        .font(.caption)
                }
            }
            .padding(.horizontal)

            List(Array(vm.searchHistory.enumerated()), id: \.offset) { _, term in
                Text(term).font(.callout.monospaced())
            }

            Text("Empty strings are filtered out.\nDuplicate consecutive terms are skipped.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .navigationTitle("Filter")
        .task { await vm.startObserving() }
    }
}

#Preview {
    NavigationStack { Recipe05_Filter() }
}
