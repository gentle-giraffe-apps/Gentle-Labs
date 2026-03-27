import SwiftUI

// MARK: - Card Detail View

struct CardDetailView: View {
    let card: Card

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                cardImage
                cardInfo
            }
            .padding()
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Image

    @ViewBuilder
    private var cardImage: some View {
        if let url = card.images?.largeURL {
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
            imagePlaceholder(systemName: "photo")
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
        .frame(height: 400)
    }

    // MARK: - Info

    private var cardInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Name & Supertype
            VStack(alignment: .leading, spacing: 6) {
                Text(card.name)
                    .font(.title2.bold())

                if let supertype = card.supertype {
                    let subtitle = [supertype, card.subtypes?.joined(separator: " · ")]
                        .compactMap { $0 }
                        .joined(separator: " — ")
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Details Grid
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 12
            ) {
                if let hp = card.hp {
                    DetailCell(label: "HP", value: hp)
                }
                if let types = card.types, !types.isEmpty {
                    DetailCell(label: "Type", value: types.joined(separator: ", "))
                }
                if let rarity = card.rarity {
                    DetailCell(label: "Rarity", value: rarity)
                }
                if let set = card.set {
                    DetailCell(label: "Set", value: set.name)
                }
                if let number = card.number {
                    DetailCell(label: "Number", value: number)
                }
                if let artist = card.artist {
                    DetailCell(label: "Artist", value: artist)
                }
                if let evolvesFrom = card.evolvesFrom {
                    DetailCell(label: "Evolves From", value: evolvesFrom)
                }
                if let retreatCost = card.convertedRetreatCost {
                    DetailCell(label: "Retreat Cost", value: "\(retreatCost)")
                }
            }

            // Attacks
            if let attacks = card.attacks, !attacks.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Text("Attacks")
                        .font(.headline)

                    ForEach(attacks, id: \.name) { attack in
                        AttackRow(attack: attack)
                    }
                }
            }

            // Weaknesses & Resistances
            if let weaknesses = card.weaknesses, !weaknesses.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weaknesses")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(weaknesses.map { "\($0.type) \($0.value)" }.joined(separator: ", "))
                        .font(.subheadline)
                }
            }

            if let resistances = card.resistances, !resistances.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resistances")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(resistances.map { "\($0.type) \($0.value)" }.joined(separator: ", "))
                        .font(.subheadline)
                }
            }
        }
    }
}

// MARK: - Attack Row

private struct AttackRow: View {
    let attack: Attack

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(attack.name)
                    .font(.subheadline.bold())
                Spacer()
                if let damage = attack.damage, !damage.isEmpty {
                    Text(damage)
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                }
            }

            if let cost = attack.cost, !cost.isEmpty {
                Text("Cost: \(cost.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let text = attack.text, !text.isEmpty {
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.quaternary)
        )
    }
}

// MARK: - Detail Cell

private struct DetailCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        CardDetailView(
            card: Card(
                id: "base1-4",
                name: "Charizard",
                supertype: "Pokémon",
                subtypes: ["Stage 2"],
                hp: "120",
                types: ["Fire"],
                evolvesFrom: "Charmeleon",
                attacks: [
                    Attack(
                        name: "Fire Spin",
                        cost: ["Fire", "Fire", "Fire", "Fire"],
                        convertedEnergyCost: 4,
                        damage: "100",
                        text: "Discard 2 Energy cards attached to Charizard in order to use this attack."
                    )
                ],
                weaknesses: [TypeValue(type: "Water", value: "×2")],
                resistances: [TypeValue(type: "Fighting", value: "-30")],
                retreatCost: ["Colorless", "Colorless", "Colorless"],
                convertedRetreatCost: 3,
                set: CardSet(id: "base1", name: "Base"),
                number: "4",
                artist: "Mitsuhiro Arita",
                rarity: "Rare Holo",
                nationalPokedexNumbers: [6],
                images: CardImages(
                    small: "https://images.pokemontcg.io/base1/4.png",
                    large: "https://images.pokemontcg.io/base1/4_hires.png"
                )
            )
        )
    }
}
