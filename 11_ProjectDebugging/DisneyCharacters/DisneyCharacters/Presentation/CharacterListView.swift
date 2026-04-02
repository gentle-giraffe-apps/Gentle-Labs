import SmartAsyncImage
import SwiftUI

// MARK: - Character List View

struct CharacterListView: View {
    @State private var viewModel: CharacterListViewModel

    init(viewModel: CharacterListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .initial:
                    ProgressView("Starting up…")
                case .loading:
                    ProgressView("Loading characters…")
                case .refreshing, .loaded:
                    if viewModel.characters.isEmpty {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    } else {
                        characterList(items: viewModel.characters)
                    }
                case .error(let message):
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try Again") {
                            Task { await viewModel.refresh() }
                        }
                    }
                }
            }
            .navigationTitle("Disney Characters")
            .searchable(text: $viewModel.searchText, prompt: "Search characters…")
            .task {
                await viewModel.initialFetch()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Subviews

    private func characterList(items: [DisneyCharacter]) -> some View {
        List {
            ForEach(items) { character in
                NavigationLink(value: character) {
                    CharacterRow(character: character)
                }
                .task {
                    await viewModel.fetchNextPageIfNeeded(currentItem: character)
                }
            }

            if viewModel.searchText.isEmpty && viewModel.characters.count < viewModel.totalPages * 20 {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: DisneyCharacter.self) { character in
            CharacterDetailView(character: character)
        }
    }
}

// MARK: - Character Row

struct CharacterRow: View {
    let character: DisneyCharacter

    var body: some View {
        HStack(spacing: 12) {
            SmartAsyncImage(url: character.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(.secondary)
                case .empty, .loading:
                    ProgressView()
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .background(
                Circle()
                    .fill(.quaternary)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .lineLimit(2)

                if !character.films.isEmpty {
                    Text(character.films.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if !character.tvShows.isEmpty {
                    Text(character.tvShows.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview("Live") {
    CharacterListView(viewModel: CharacterListViewModel(service: NetworkCharacterService()))
}

#Preview("Mock") {
    CharacterListView(viewModel: CharacterListViewModel(service: MockCharacterService()))
}

#Preview("Empty") {
    CharacterListView(viewModel: CharacterListViewModel(service: EmptyCharacterService()))
}

#Preview("Error") {
    CharacterListView(viewModel: CharacterListViewModel(service: FailingCharacterService()))
}
