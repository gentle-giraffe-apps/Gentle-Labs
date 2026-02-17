import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 07: Merge
// ─────────────────────────────────────────────────────────────
// .merge combines multiple publishers of the SAME type into
// one stream. Values arrive in the order they're emitted —
// interleaved chronologically.
//
// Unlike combineLatest (which pairs latest values), merge
// just forwards each value from every source as it arrives.
// ─────────────────────────────────────────────────────────────

final class MergeViewModel: ObservableObject {
    let buttonA = PassthroughSubject<Void, Never>()
    let buttonB = PassthroughSubject<Void, Never>()
    let buttonC = PassthroughSubject<Void, Never>()

    @Published private(set) var events: [String] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        let streamA = buttonA.map { "[A] tapped" }
        let streamB = buttonB.map { "[B] tapped" }
        let streamC = buttonC.map { "[C] tapped" }

        streamA
            .merge(with: streamB, streamC)
            .sink { [weak self] event in
                self?.events.append(event)
            }
            .store(in: &cancellables)
    }

    func clear() { events.removeAll() }
}

struct Recipe07_Merge: View {
    @StateObject private var vm = MergeViewModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Button("A") { vm.buttonA.send() }
                    .buttonStyle(.bordered).tint(.red)
                Button("B") { vm.buttonB.send() }
                    .buttonStyle(.bordered).tint(.green)
                Button("C") { vm.buttonC.send() }
                    .buttonStyle(.bordered).tint(.blue)
            }
            .font(.title3.bold())

            HStack {
                Text("Event Log").font(.headline)
                Spacer()
                if !vm.events.isEmpty {
                    Button("Clear") { vm.clear() }
                        .font(.caption)
                }
            }
            .padding(.horizontal)

            List(Array(vm.events.enumerated()), id: \.offset) { i, event in
                Text("\(i + 1). \(event)")
                    .font(.callout.monospaced())
            }
        }
        .navigationTitle("Merge")
    }
}

#Preview {
    NavigationStack { Recipe07_Merge() }
}
