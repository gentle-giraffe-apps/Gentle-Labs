import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 03: Debounce
// ─────────────────────────────────────────────────────────────
// .debounce waits until the publisher stops emitting for a
// given duration, then emits the latest value. Perfect for
// search: wait until the user stops typing.
//
// .removeDuplicates skips consecutive identical values so
// you don't re-run a search for the same text.
//
// .sink subscribes to the publisher and runs a closure for
// each value. You must store the AnyCancellable it returns.
// ─────────────────────────────────────────────────────────────

final class DebounceViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var debouncedText = ""
    @Published private(set) var searchCount = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                debouncedText = text
                if !text.isEmpty { searchCount += 1 }
            }
            .store(in: &cancellables)
    }
}

struct Recipe03_Debounce: View {
    @StateObject private var vm = DebounceViewModel()

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
    }
}

#Preview {
    NavigationStack { Recipe03_Debounce() }
}
