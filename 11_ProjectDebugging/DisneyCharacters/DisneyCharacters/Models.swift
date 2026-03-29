import Foundation

// MARK: - Content Loading State

enum ContentLoadingState: Equatable, Sendable {
    case initial
    case loading
    case refreshing
    case loaded
    case error(String)
}

// MARK: - API Response

struct CharacterResponse: Codable, Sendable {
    let info: PageInfo
    let data: [DisneyCharacter]
}

struct PageInfo: Codable, Sendable {
    let count: Int
    let totalPages: Int
    let previousPage: String?
    let nextPage: String?
}

// MARK: - Character Model

struct DisneyCharacter: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let films: [String]
    let shortFilms: [String]
    let tvShows: [String]
    let videoGames: [String]
    let parkAttractions: [String]
    let allies: [String]
    let enemies: [String]
    let imageUrl: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, films, shortFilms, tvShows, videoGames
        case parkAttractions, allies, enemies, imageUrl, url
    }

    var imageURL: URL? {
        guard let imageUrl else { return nil }
        return URL(string: imageUrl)
    }
}
