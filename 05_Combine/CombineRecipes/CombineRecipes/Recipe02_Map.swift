import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 02: Map
// ─────────────────────────────────────────────────────────────
// $name gives you the Combine publisher behind @Published.
// .map transforms each emitted value — just like map on
// arrays, but for values over time.
//
// assign(to: &$otherProperty) connects two @Published
// properties without needing to store a cancellable.
// ─────────────────────────────────────────────────────────────

final class MapViewModel: ObservableObject {
    @Published var name = ""
    @Published private(set) var greeting = ""
    @Published private(set) var characterCount = 0

    init() {
        // $name is a Publisher<String, Never>
        // .map transforms each String into a greeting
        $name
            .map { $0.isEmpty ? "Type your name below" : "Hello, \($0)!" }
            .assign(to: &$greeting)

        $name
            .map { $0.count }
            .assign(to: &$characterCount)
    }
}

struct Recipe02_Map: View {
    @StateObject private var vm = MapViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text(vm.greeting)
                .font(.title2)

            TextField("Your name", text: $vm.name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Text("\(vm.characterCount) characters")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Map")
    }
}

#Preview {
    NavigationStack { Recipe02_Map() }
}
