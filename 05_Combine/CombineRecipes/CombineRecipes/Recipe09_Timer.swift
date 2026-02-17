import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 09: Timer
// ─────────────────────────────────────────────────────────────
// Timer.publish(every:on:in:) creates a publisher that fires
// at regular intervals.
//
// .autoconnect() starts it automatically on first subscriber.
// Store the cancellable separately so you can cancel (pause)
// the timer independently.
// ─────────────────────────────────────────────────────────────

final class StopwatchViewModel: ObservableObject {
    @Published private(set) var secondsElapsed = 0
    @Published private(set) var isRunning = false

    private var timerCancellable: AnyCancellable?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.secondsElapsed += 1
            }
    }

    func stop() {
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func reset() {
        stop()
        secondsElapsed = 0
    }
}

struct Recipe09_Timer: View {
    @StateObject private var vm = StopwatchViewModel()

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
