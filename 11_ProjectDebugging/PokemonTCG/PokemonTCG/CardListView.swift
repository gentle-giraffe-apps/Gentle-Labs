import SwiftUI

// MARK: - Card List View

struct CardListView: View {
    @State private var viewModel: CardListViewModel

    init(viewModel: CardListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .unloaded:
                    ProgressView("Starting up…")
                case .loading:
                    ProgressView("Loading cards…")
                case .refreshing:
                    cardList(items: viewModel.cards)
                        .overlay {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .padding(.top, 8)
                        }
                case .loaded:
                    if viewModel.cards.isEmpty {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    } else {
                        cardList(items: viewModel.cards)
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
            .navigationTitle("Pokémon TCG")
            .searchable(text: $viewModel.searchText, prompt: "Search cards…")
            .task {
                await viewModel.initialFetch()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Subviews

    private func cardList(items: [Card]) -> some View {
        List {
            ForEach(items) { card in
                NavigationLink(value: card) {
                    CardRow(card: card)
                }
                .task {
                    await viewModel.fetchNextPageIfNeeded(currentItem: card)
                }
            }

            if viewModel.cards.count < viewModel.totalCount {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Card.self) { card in
            CardDetailView(card: card)
        }
    }
}

// MARK: - Card Row

struct CardRow: View {
    let card: Card

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: card.images?.smallURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(width: 60, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(.quaternary)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.headline)
                    .lineLimit(2)

                if let types = card.types, !types.isEmpty {
                    Text(types.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    if let hp = card.hp {
                        Text("HP \(hp)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    if let rarity = card.rarity {
                        Text(rarity)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview("Live") {
    CardListView(viewModel: CardListViewModel(service: NetworkCardService()))
}

#Preview("Mock") {
    CardListView(viewModel: CardListViewModel(service: MockCardService()))
}

#Preview("Empty") {
    CardListView(viewModel: CardListViewModel(service: EmptyCardService()))
}

#Preview("Error") {
    CardListView(viewModel: CardListViewModel(service: FailingCardService()))
}
