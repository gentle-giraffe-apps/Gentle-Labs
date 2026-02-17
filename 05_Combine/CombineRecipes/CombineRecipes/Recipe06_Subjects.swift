import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 06: Subjects
// ─────────────────────────────────────────────────────────────
// Subjects are publishers YOU send values to manually.
//
// PassthroughSubject — no stored value. It just forwards
//   whatever you .send() to current subscribers.
//
// CurrentValueSubject — holds the latest value. New
//   subscribers immediately get the current value, then
//   receive future updates.
// ─────────────────────────────────────────────────────────────

final class SubjectsViewModel: ObservableObject {
    // PassthroughSubject: fire-and-forget pipe
    let tap = PassthroughSubject<String, Never>()

    // CurrentValueSubject: always has a current value
    let toggle = CurrentValueSubject<Bool, Never>(false)

    @Published private(set) var tapLog: [String] = []
    @Published private(set) var toggleState = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        tap
            .sink { [weak self] word in
                self?.tapLog.append(word)
            }
            .store(in: &cancellables)

        toggle
            .sink { [weak self] value in
                self?.toggleState = value
            }
            .store(in: &cancellables)
    }
}

struct Recipe06_Subjects: View {
    @StateObject private var vm = SubjectsViewModel()

    var body: some View {
        VStack(spacing: 24) {
            GroupBox("PassthroughSubject") {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button("Hello") { vm.tap.send("Hello") }
                        Button("World") { vm.tap.send("World") }
                        Button("!") { vm.tap.send("!") }
                    }
                    .buttonStyle(.bordered)

                    Text(vm.tapLog.joined(separator: " "))
                        .font(.callout.monospaced())
                        .frame(maxWidth: .infinity, minHeight: 30,
                               alignment: .leading)
                }
            }

            GroupBox("CurrentValueSubject") {
                VStack(spacing: 12) {
                    Toggle("Enabled", isOn: Binding(
                        get: { vm.toggleState },
                        set: { vm.toggle.send($0) }
                    ))

                    Text("Current value: \(vm.toggleState ? "ON" : "OFF")")
                        .font(.callout.monospaced())
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("Subjects")
    }
}

#Preview {
    NavigationStack { Recipe06_Subjects() }
}
