import Foundation

// MARK: - Service Protocol

protocol CharacterService: Sendable {
    func fetchCharacters(page: Int, pageSize: Int) async throws -> CharacterResponse
    func searchCharacters(query: String, page: Int, pageSize: Int) async throws -> CharacterResponse
}

// MARK: - API Constants

private enum APIConstants {
    static let baseURL = "https://api.disneyapi.dev"
}

// MARK: - Network Service

struct NetworkCharacterService: CharacterService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchCharacters(page: Int, pageSize: Int) async throws -> CharacterResponse {
        var components = URLComponents(string: "\(APIConstants.baseURL)/character")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
        ]
        return try await performRequest(url: components.url!)
    }

    func searchCharacters(query: String, page: Int, pageSize: Int) async throws -> CharacterResponse {
        var components = URLComponents(string: "\(APIConstants.baseURL)/character")!
        components.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
        ]
        return try await performRequest(url: components.url!)
    }

    private func performRequest(url: URL) async throws -> CharacterResponse {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(CharacterResponse.self, from: data)
    }
}

// MARK: - Mock Service

struct MockCharacterService: CharacterService {
    private let itemsPerPage: Int
    private let totalItems: Int

    init(itemsPerPage: Int = 20, totalItems: Int = 55) {
        self.itemsPerPage = itemsPerPage
        self.totalItems = totalItems
    }

    func fetchCharacters(page: Int, pageSize: Int) async throws -> CharacterResponse {
        try await Task.sleep(for: .milliseconds(600))
        return makeResponse(page: page, pageSize: pageSize)
    }

    func searchCharacters(query: String, page: Int, pageSize: Int) async throws -> CharacterResponse {
        try await Task.sleep(for: .milliseconds(400))
        let response = makeResponse(page: page, pageSize: pageSize)
        let filtered = response.data.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
        return CharacterResponse(
            info: PageInfo(count: filtered.count, totalPages: 1, previousPage: nil, nextPage: nil),
            data: filtered
        )
    }

    private func makeResponse(page: Int, pageSize: Int) -> CharacterResponse {
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, totalItems)
        let totalPages = (totalItems + pageSize - 1) / pageSize

        let characters: [DisneyCharacter] = (startIndex..<endIndex).map { i in
            let films = [["Frozen", "Frozen II"], ["The Lion King"], ["Aladdin", "Aladdin (2019)"], ["Moana"], ["Tangled"]]
            let shows = [["Mickey Mouse Clubhouse"], ["DuckTales"], ["The Mandalorian"], [], ["Lilo & Stitch: The Series"]]
            return DisneyCharacter(
                id: i + 1,
                name: "Character \(i + 1)",
                films: films[i % films.count],
                shortFilms: [],
                tvShows: shows[i % shows.count],
                videoGames: ["Disney Dreamlight Valley"],
                parkAttractions: ["Meet and Greet"],
                allies: ["Character \((i + 2) % totalItems + 1)"],
                enemies: [],
                imageUrl: nil,
                url: nil
            )
        }

        let nextPage = page < totalPages ? "https://api.disneyapi.dev/character?page=\(page + 1)&pageSize=\(pageSize)" : nil
        let previousPage = page > 1 ? "https://api.disneyapi.dev/character?page=\(page - 1)&pageSize=\(pageSize)" : nil

        return CharacterResponse(
            info: PageInfo(count: totalItems, totalPages: totalPages, previousPage: previousPage, nextPage: nextPage),
            data: characters
        )
    }
}

// MARK: - Empty Service

struct EmptyCharacterService: CharacterService {
    func fetchCharacters(page: Int, pageSize: Int) async throws -> CharacterResponse {
        CharacterResponse(
            info: PageInfo(count: 0, totalPages: 0, previousPage: nil, nextPage: nil),
            data: []
        )
    }

    func searchCharacters(query: String, page: Int, pageSize: Int) async throws -> CharacterResponse {
        try await fetchCharacters(page: page, pageSize: pageSize)
    }
}

// MARK: - Failing Service

struct FailingCharacterService: CharacterService {
    func fetchCharacters(page: Int, pageSize: Int) async throws -> CharacterResponse {
        try await Task.sleep(for: .milliseconds(300))
        throw URLError(.timedOut)
    }

    func searchCharacters(query: String, page: Int, pageSize: Int) async throws -> CharacterResponse {
        try await fetchCharacters(page: page, pageSize: pageSize)
    }
}
