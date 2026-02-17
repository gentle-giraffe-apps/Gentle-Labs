import AsyncAlgorithms
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 09: Timer
// ─────────────────────────────────────────────────────────────
// Combine equivalent: Timer.publish(every:on:in:).autoconnect()
//
// AsyncTimerSequence from AsyncAlgorithms emits at regular
// intervals. Iterate with for-await. Cancel the Task to stop.
//
// No autoconnect, no AnyCancellable — just a Task you cancel.
// ─────────────────────────────────────────────────────────────

@Observable
class StopwatchViewModel {
    private(set) var secondsElapsed = 0
    private(set) var isRunning = false

    private var timerTask: Task<Void, Never>?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timerTask = Task {
            for await _ in AsyncTimerSequence(
                interval: .seconds(1),
                clock: .continuous
            ) {
                secondsElapsed += 1
            }
        }
    }

    func stop() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    func reset() {
        stop()
        secondsElapsed = 0
    }
}

struct Recipe09_Timer: View {
    @State private var vm = StopwatchViewModel()

    var body: some View {
        VStack(spacing: 32) {
            Text(formatted(vm.secondsElapsed))
                .font(.system(size: 64, weight: .thin, design: .monospaced))

            HStack(spacing: 20) {
                Button(vm.isRunning ? "Stop" : "Start") {
                    vm.isRunning ? vm.stop() : vm.start()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") { vm.reset() }
                    .buttonStyle(.bordered)
                    .disabled(vm.secondsElapsed == 0 && !vm.isRunning)
            }
        }
        .navigationTitle("Timer")
    }

    private func formatted(_ total: Int) -> String {
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    NavigationStack { Recipe09_Timer() }
}
