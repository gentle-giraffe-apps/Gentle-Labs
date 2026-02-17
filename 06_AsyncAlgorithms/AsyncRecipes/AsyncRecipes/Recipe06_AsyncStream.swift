import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 06: AsyncStream (replaces Subjects)
// ─────────────────────────────────────────────────────────────
// Combine equivalent: PassthroughSubject / CurrentValueSubject
//
// AsyncStream + Continuation replaces PassthroughSubject:
//   • .makeStream(of:) gives you a stream and its continuation
//   • continuation.yield() sends values (like subject.send())
//   • for-await consumes values (like .sink)
//
// CurrentValueSubject has no direct equivalent — but @Observable
// properties serve the same purpose: hold a value and notify
// observers when it changes.
// ─────────────────────────────────────────────────────────────

@Observable
class AsyncStreamViewModel {
    // AsyncStream replaces PassthroughSubject
    private(set) var tapLog: [String] = []
    private let tapContinuation: AsyncStream<String>.Continuation
    let tapStream: AsyncStream<String>

    // @Observable property replaces CurrentValueSubject
    var toggleState = false

    init() {
        let (stream, continuation) = AsyncStream.makeStream(of: String.self)
        self.tapStream = stream
        self.tapContinuation = continuation
    }

    func sendTap(_ word: String) {
        tapContinuation.yield(word)
    }

    func startListening() async {
        for await word in tapStream {
            tapLog.append(word)
        }
    }
}

struct Recipe06_AsyncStream: View {
    @State private var vm = AsyncStreamViewModel()

    var body: some View {
        VStack(spacing: 24) {
            GroupBox("AsyncStream (replaces PassthroughSubject)") {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button("Hello") { vm.sendTap("Hello") }
                        Button("World") { vm.sendTap("World") }
                        Button("!") { vm.sendTap("!") }
                    }
                    .buttonStyle(.bordered)

                    Text(vm.tapLog.joined(separator: " "))
                        .font(.callout.monospaced())
                        .frame(maxWidth: .infinity, minHeight: 30,
                               alignment: .leading)
                }
            }

            GroupBox("@Observable (replaces CurrentValueSubject)") {
                VStack(spacing: 12) {
                    Toggle("Enabled", isOn: $vm.toggleState)
                    Text("Current value: \(vm.toggleState ? "ON" : "OFF")")
                        .font(.callout.monospaced())
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("AsyncStream")
        .task { await vm.startListening() }
    }
}

#Preview {
    NavigationStack { Recipe06_AsyncStream() }
}
