import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 05: Filter & RemoveDuplicates
// ─────────────────────────────────────────────────────────────
// .filter only lets values through that satisfy a condition.
// .removeDuplicates skips consecutive identical values.
//
// Combine them to build a clean search-history log: only
// non-empty, unique, trimmed terms get recorded.
// ─────────────────────────────────────────────────────────────

final class FilterViewModel: ObservableObject {
    @Published var inputText = ""
    @Published private(set) var searchHistory: [String] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        $inputText
            .debounce(for: .seconds(0.4), scheduler: RunLoop.main)
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .sink { [weak self] term in
                self?.searchHistory.append(term)
            }
            .store(in: &cancellables)
    }

    func clearHistory() { searchHistory.removeAll() }
}

struct Recipe05_Filter: View {
    @StateObject private var vm = FilterViewModel()

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
    }
}

#Preview {
    NavigationStack { Recipe05_Filter() }
}
