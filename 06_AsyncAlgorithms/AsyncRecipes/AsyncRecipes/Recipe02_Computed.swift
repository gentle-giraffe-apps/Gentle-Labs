import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 02: Computed Properties (replaces .map)
// ─────────────────────────────────────────────────────────────
// Combine equivalent: $name.map { ... }.assign(to: &$greeting)
//
// With @Observable, computed properties replace .map pipelines
// entirely. No publisher, no operator chain, no cancellable.
//
// @Observable tracks which stored properties each computed
// property reads. When a dependency changes, SwiftUI
// re-evaluates only views that read that computed property.
// ─────────────────────────────────────────────────────────────

@Observable
class MapViewModel {
    var name = ""

    var greeting: String {
        name.isEmpty ? "Type your name below" : "Hello, \(name)!"
    }

    var characterCount: Int { name.count }
}

struct Recipe02_Computed: View {
    @State private var vm = MapViewModel()

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
        .navigationTitle("Computed Properties")
    }
}

#Preview {
    NavigationStack { Recipe02_Computed() }
}
