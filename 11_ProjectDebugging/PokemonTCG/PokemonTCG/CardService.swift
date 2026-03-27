import Foundation

// MARK: - Service Protocol

protocol CardService: Sendable {
    func fetchCards(page: Int, pageSize: Int) async throws -> CardResponse
    func searchCards(query: String, page: Int, pageSize: Int) async throws -> CardResponse
}

// MARK: - API Constants

private enum APIConstants {
    static let baseURL = "https://api.pokemontcg.io/v2"
}

// MARK: - Network Service

struct NetworkCardService: CardService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchCards(page: Int, pageSize: Int) async throws -> CardResponse {
        var components = URLComponents(string: "\(APIConstants.baseURL)/cards")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
        ]
        return try await performRequest(url: components.url!)
    }

    func searchCards(query: String, page: Int, pageSize: Int) async throws -> CardResponse {
        var components = URLComponents(string: "\(APIConstants.baseURL)/cards")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "name:\(query)*"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
        ]
        return try await performRequest(url: components.url!)
    }

    private func performRequest(url: URL) async throws -> CardResponse {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(CardResponse.self, from: data)
    }
}

// MARK: - Mock Service

struct MockCardService: CardService {
    private let itemsPerPage: Int
    private let totalItems: Int

    init(itemsPerPage: Int = 20, totalItems: Int = 55) {
        self.itemsPerPage = itemsPerPage
        self.totalItems = totalItems
    }

    func fetchCards(page: Int, pageSize: Int) async throws -> CardResponse {
        try await Task.sleep(for: .milliseconds(600))
        return makeResponse(page: page, pageSize: pageSize)
    }

    func searchCards(query: String, page: Int, pageSize: Int) async throws -> CardResponse {
        try await Task.sleep(for: .milliseconds(400))
        let response = makeResponse(page: page, pageSize: pageSize)
        let filtered = response.data.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
        return CardResponse(
            data: filtered,
            page: 1,
            pageSize: pageSize,
            count: filtered.count,
            totalCount: filtered.count
        )
    }

    private func makeResponse(page: Int, pageSize: Int) -> CardResponse {
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, totalItems)

        let cards: [Card] = (startIndex..<endIndex).map { i in
            let types = ["Fire", "Water", "Grass", "Electric", "Psychic"]
            let rarities = ["Common", "Uncommon", "Rare", "Rare Holo"]
            return Card(
                id: "mock-\(i + 1)",
                name: "Pokémon \(i + 1)",
                supertype: "Pokémon",
                subtypes: ["Basic"],
                hp: "\(50 + (i % 5) * 20)",
                types: [types[i % types.count]],
                evolvesFrom: nil,
                attacks: [
                    Attack(
                        name: "Attack \(i + 1)",
                        cost: [types[i % types.count]],
                        convertedEnergyCost: 1,
                        damage: "\(20 + i * 10)",
                        text: "A powerful attack."
                    )
                ],
                weaknesses: [TypeValue(type: types[(i + 1) % types.count], value: "×2")],
                resistances: nil,
                retreatCost: ["Colorless"],
                convertedRetreatCost: 1,
                set: CardSet(id: "mock-set", name: "Mock Set"),
                number: "\(i + 1)",
                artist: "Mock Artist",
                rarity: rarities[i % rarities.count],
                nationalPokedexNumbers: [i + 1],
                images: nil
            )
        }

        return CardResponse(
            data: cards,
            page: page,
            pageSize: pageSize,
            count: cards.count,
            totalCount: totalItems
        )
    }
}

// MARK: - Empty Service

struct EmptyCardService: CardService {
    func fetchCards(page: Int, pageSize: Int) async throws -> CardResponse {
        CardResponse(data: [], page: 1, pageSize: pageSize, count: 0, totalCount: 0)
    }

    func searchCards(query: String, page: Int, pageSize: Int) async throws -> CardResponse {
        try await fetchCards(page: page, pageSize: pageSize)
    }
}

// MARK: - Failing Service

struct FailingCardService: CardService {
    func fetchCards(page: Int, pageSize: Int) async throws -> CardResponse {
        try await Task.sleep(for: .milliseconds(300))
        throw URLError(.timedOut)
    }

    func searchCards(query: String, page: Int, pageSize: Int) async throws -> CardResponse {
        try await fetchCards(page: page, pageSize: pageSize)
    }
}
