import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 01: @Observable
// ─────────────────────────────────────────────────────────────
// Combine equivalent: ObservableObject + @Published + @StateObject
//
// @Observable (iOS 17) replaces all three:
//   • No ObservableObject conformance needed
//   • No @Published on each property
//   • @State instead of @StateObject
//
// SwiftUI automatically tracks which properties the view reads
// and re-renders only when those specific properties change.
// Finer-grained than Combine's objectWillChange, which re-renders
// the view for ANY @Published change.
// ─────────────────────────────────────────────────────────────

@Observable
class CounterViewModel {
    var count = 0
}

struct Recipe01_Observable: View {
    @State private var vm = CounterViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("\(vm.count)")
                .font(.system(size: 72, weight: .bold, design: .rounded))

            HStack(spacing: 40) {
                Button { vm.count -= 1 } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                }
                Button { vm.count += 1 } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                }
            }
        }
        .navigationTitle("@Observable")
    }
}

#Preview {
    NavigationStack { Recipe01_Observable() }
}
