import SwiftUI

// MARK: - Explore View

struct ExploreView: View {
    @State private var viewModel: ExploreViewModel

    init(viewModel: ExploreViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .initial, .loading:
                    ProgressView("Loading characters…")
                case .refreshing, .loaded:
                    if viewModel.groups.isEmpty {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    } else {
                        groupList
                    }
                case .error(let message):
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try Again") {
                            viewModel.load()
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            .searchable(text: $viewModel.searchText, prompt: "Search \(viewModel.selectedGrouping.rawValue.lowercased())…")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Group by", selection: $viewModel.selectedGrouping) {
                        ForEach(CharacterGrouping.allCases) { grouping in
                            Text(grouping.rawValue).tag(grouping)
                        }
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
            }
            .task {
                viewModel.load()
            }
        }
    }

    // MARK: - Subviews

    private var groupList: some View {
        List(viewModel.groups) { group in
            NavigationLink(value: group) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.name)
                            .font(.headline)
                        Text("\(group.characterCount) character\(group.characterCount == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: CharacterGroup.self) { group in
            GroupDetailView(
                group: group,
                characters: viewModel.characters(for: group)
            )
        }
    }
}

// MARK: - Group Detail View

struct GroupDetailView: View {
    let group: CharacterGroup
    let characters: [DisneyCharacter]

    var body: some View {
        List(characters) { character in
            NavigationLink(value: character) {
                CharacterRow(character: character)
            }
        }
        .listStyle(.plain)
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: DisneyCharacter.self) { character in
            CharacterDetailView(character: character)
        }
    }
}

// MARK: - Previews

#Preview("Explore") {
    ExploreView(viewModel: ExploreViewModel(repository: LocalCharacterRepository()))
}
