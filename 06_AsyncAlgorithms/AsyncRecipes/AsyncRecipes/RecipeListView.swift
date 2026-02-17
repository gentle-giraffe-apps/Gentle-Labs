import SwiftUI

struct RecipeListView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Getting Started") {
                    recipeLink(1, "@Observable",
                               "Replaces ObservableObject + @Published") {
                        Recipe01_Observable()
                    }
                    recipeLink(2, "Computed Properties",
                               "Replaces .map pipelines entirely") {
                        Recipe02_Computed()
                    }
                }

                Section("AsyncAlgorithms Operators") {
                    recipeLink(3, "Debounce",
                               "AsyncStream + .debounce") {
                        Recipe03_Debounce()
                    }
                    recipeLink(4, "CombineLatest",
                               "Two independent async streams") {
                        Recipe04_CombineLatest()
                    }
                    recipeLink(5, "Filter & RemoveDuplicates",
                               "Built-in .filter + AsyncAlgorithms") {
                        Recipe05_Filter()
                    }
                }

                Section("Streams") {
                    recipeLink(6, "AsyncStream",
                               "Replaces PassthroughSubject") {
                        Recipe06_AsyncStream()
                    }
                    recipeLink(7, "Merge",
                               "Interleave multiple async streams") {
                        Recipe07_Merge()
                    }
                }

                Section("Real-World Patterns") {
                    recipeLink(8, "Chaining",
                               "Sequential async replaces flatMap") {
                        Recipe08_Chaining()
                    }
                    recipeLink(9, "Timer",
                               "AsyncTimerSequence") {
                        Recipe09_Timer()
                    }
                    recipeLink(10, "Networking",
                               "URLSession async/await") {
                        Recipe10_Networking()
                    }
                }
            }
            .navigationTitle("Async Recipes")
        }
    }

    private func recipeLink<Destination: View>(
        _ number: Int,
        _ title: String,
        _ subtitle: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Text(String(format: "%02d", number))
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.body.bold())
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    RecipeListView()
}
