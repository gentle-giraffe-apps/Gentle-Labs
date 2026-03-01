import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 01: @Published Basics
// ─────────────────────────────────────────────────────────────
// @Published is a Combine property wrapper. It creates a
// publisher that emits the new value every time the property
// changes. ObservableObject + @Published + @StateObject is
// the simplest way you encounter Combine in SwiftUI — often
// without realizing it.
//
// Note: This project uses SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
// (see Project.swift). All classes are implicitly @MainActor, so
// .receive(on: DispatchQueue.main) is redundant in later recipes
// but included for clarity since most Combine tutorials assume
// no default isolation.
//
// Key points:
// • @Published var count  →  behind the scenes, a Combine publisher
// • ObservableObject      →  SwiftUI listens for changes
// • @StateObject          →  view owns the object, created once
// ─────────────────────────────────────────────────────────────

final class CounterViewModel: ObservableObject {
    @Published var count = 0
}

struct Recipe01_BasicPublished: View {
    @StateObject private var vm = CounterViewModel()

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
        .navigationTitle("@Published")
    }
}

#Preview {
    NavigationStack { Recipe01_BasicPublished() }
}
