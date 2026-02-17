import SwiftUI

struct RecipeListView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Getting Started") {
                    recipeLink(1, "@Published Basics",
                               "ObservableObject + @StateObject") {
                        Recipe01_BasicPublished()
                    }
                    recipeLink(2, "Map",
                               "Transform published values") {
                        Recipe02_Map()
                    }
                }

                Section("Operators") {
                    recipeLink(3, "Debounce",
                               "Wait for typing to pause") {
                        Recipe03_Debounce()
                    }
                    recipeLink(4, "CombineLatest",
                               "Merge two publishers into one") {
                        Recipe04_CombineLatest()
                    }
                    recipeLink(5, "Filter & RemoveDuplicates",
                               "Selective emission") {
                        Recipe05_Filter()
                    }
                }

                Section("Publishers") {
                    recipeLink(6, "Subjects",
                               "Send values manually") {
                        Recipe06_Subjects()
                    }
                    recipeLink(7, "Merge",
                               "Interleave multiple streams") {
                        Recipe07_Merge()
                    }
                }

                Section("Real-World Patterns") {
                    recipeLink(8, "FlatMap",
                               "Chain dependent publishers") {
                        Recipe08_FlatMap()
                    }
                    recipeLink(9, "Timer",
                               "Periodic events with Timer.publish") {
                        Recipe09_Timer()
                    }
                    recipeLink(10, "Networking",
                               "URLSession.dataTaskPublisher") {
                        Recipe10_Networking()
                    }
                }
            }
            .navigationTitle("Combine Recipes")
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
