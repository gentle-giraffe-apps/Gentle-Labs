import SwiftUI

// MARK: - Character Detail View

struct CharacterDetailView: View {
    let character: DisneyCharacter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                characterImage
                characterInfo
            }
            .padding()
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Image

    @ViewBuilder
    private var characterImage: some View {
        if let url = character.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                case .failure:
                    imagePlaceholder(systemName: "exclamationmark.triangle")
                default:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 400)
                }
            }
        } else {
            imagePlaceholder(systemName: "person.circle.fill")
        }
    }

    private func imagePlaceholder(systemName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.quaternary)
            Image(systemName: systemName)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
        .frame(height: 300)
    }

    // MARK: - Info

    private var characterInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(character.name)
                .font(.title2.bold())

            Divider()

            // Appearances
            if !character.films.isEmpty {
                AppearanceSection(title: "Films", items: character.films, icon: "film")
            }

            if !character.tvShows.isEmpty {
                AppearanceSection(title: "TV Shows", items: character.tvShows, icon: "tv")
            }

            if !character.shortFilms.isEmpty {
                AppearanceSection(title: "Short Films", items: character.shortFilms, icon: "film.stack")
            }

            if !character.videoGames.isEmpty {
                AppearanceSection(title: "Video Games", items: character.videoGames, icon: "gamecontroller")
            }

            if !character.parkAttractions.isEmpty {
                AppearanceSection(title: "Park Attractions", items: character.parkAttractions, icon: "mappin.and.ellipse")
            }

            // Relationships
            if !character.allies.isEmpty {
                Divider()
                AppearanceSection(title: "Allies", items: character.allies, icon: "person.2")
            }

            if !character.enemies.isEmpty {
                AppearanceSection(title: "Enemies", items: character.enemies, icon: "person.2.slash")
            }
        }
    }
}

// MARK: - Appearance Section

private struct AppearanceSection: View {
    let title: String
    let items: [String]
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.quaternary)
                        )
                }
            }
        }
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        CharacterDetailView(
            character: DisneyCharacter(
                id: 308,
                name: "Mickey Mouse",
                films: ["Fantasia", "Fun and Fancy Free", "Mickey's Christmas Carol"],
                shortFilms: ["Steamboat Willie", "The Band Concert"],
                tvShows: ["Mickey Mouse Clubhouse", "Mickey Mouse Mixed-Up Adventures"],
                videoGames: ["Kingdom Hearts", "Disney Dreamlight Valley", "Epic Mickey"],
                parkAttractions: ["Meet Mickey Mouse", "Mickey's PhilharMagic"],
                allies: ["Donald Duck", "Goofy", "Minnie Mouse", "Pluto"],
                enemies: ["Pete", "Mortimer Mouse"],
                imageUrl: "https://static.wikia.nocookie.net/disney/images/9/99/Mickey_Mouse_Disney_3.jpeg",
                url: "https://api.disneyapi.dev/character/308"
            )
        )
    }
}
