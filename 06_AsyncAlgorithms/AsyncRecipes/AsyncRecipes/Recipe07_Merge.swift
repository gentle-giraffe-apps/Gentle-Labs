import AsyncAlgorithms
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 07: Merge
// ─────────────────────────────────────────────────────────────
// Combine equivalent: streamA.merge(with: streamB, streamC).sink
//
// AsyncAlgorithms' merge() combines multiple async sequences
// of the SAME type into one interleaved stream.
//
// The for-await loop receives values from all sources as they
// arrive. Cancelling the Task cancels the entire merged stream.
// ─────────────────────────────────────────────────────────────

@Observable
class MergeViewModel {
    private(set) var events: [String] = []

    private let contA: AsyncStream<String>.Continuation
    private let contB: AsyncStream<String>.Continuation
    private let contC: AsyncStream<String>.Continuation
    private let streamA: AsyncStream<String>
    private let streamB: AsyncStream<String>
    private let streamC: AsyncStream<String>

    init() {
        (streamA, contA) = AsyncStream.makeStream(of: String.self)
        (streamB, contB) = AsyncStream.makeStream(of: String.self)
        (streamC, contC) = AsyncStream.makeStream(of: String.self)
    }

    func tapA() { contA.yield("[A] tapped") }
    func tapB() { contB.yield("[B] tapped") }
    func tapC() { contC.yield("[C] tapped") }

    func startListening() async {
        for await event in merge(streamA, streamB, streamC) {
            events.append(event)
        }
    }

    func clear() { events.removeAll() }
}

struct Recipe07_Merge: View {
    @State private var vm = MergeViewModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Button("A") { vm.tapA() }
                    .buttonStyle(.bordered).tint(.red)
                Button("B") { vm.tapB() }
                    .buttonStyle(.bordered).tint(.green)
                Button("C") { vm.tapC() }
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
        .task { await vm.startListening() }
    }
}

#Preview {
    NavigationStack { Recipe07_Merge() }
}
