import AsyncAlgorithms
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 03: Debounce
// ─────────────────────────────────────────────────────────────
// Combine equivalent: $searchText.debounce(for:scheduler:).sink
//
// With async: create an AsyncStream from text changes (via
// didSet), then apply .debounce from AsyncAlgorithms.
//
// The for-await loop IS the subscriber. Cancelling the Task
// (via .task modifier) cancels the loop — no AnyCancellable.
// ─────────────────────────────────────────────────────────────

@Observable
class DebounceViewModel {
    var searchText = "" {
        didSet { continuation?.yield(searchText) }
    }
    private(set) var debouncedText = ""
    private(set) var searchCount = 0

    private var continuation: AsyncStream<String>.Continuation?

    func startObserving() async {
        let stream = AsyncStream<String> { continuation in
            self.continuation = continuation
        }

        for await text in stream.debounce(for: .seconds(0.5)) {
            debouncedText = text
            if !text.isEmpty { searchCount += 1 }
        }
    }
}

struct Recipe03_Debounce: View {
    @State private var vm = DebounceViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Search...", text: $vm.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Typing: \"\(vm.searchText)\"",
                          systemImage: "keyboard")
                    Label("Debounced: \"\(vm.debouncedText)\"",
                          systemImage: "timer")
                    Label("Searches fired: \(vm.searchCount)",
                          systemImage: "magnifyingglass")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            Text("Type quickly — the debounced value updates\nonly after 0.5 s of silence.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .navigationTitle("Debounce")
        .task { await vm.startObserving() }
    }
}

#Preview {
    NavigationStack { Recipe03_Debounce() }
}
