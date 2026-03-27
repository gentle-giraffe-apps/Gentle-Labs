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

struct CardResponse: Codable, Sendable {
    let data: [Card]
    let page: Int
    let pageSize: Int
    let count: Int
    let totalCount: Int
}

// MARK: - Card Model

struct Card: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let supertype: String?
    let subtypes: [String]?
    let hp: String?
    let types: [String]?
    let evolvesFrom: String?
    let attacks: [Attack]?
    let weaknesses: [TypeValue]?
    let resistances: [TypeValue]?
    let retreatCost: [String]?
    let convertedRetreatCost: Int?
    let set: CardSet?
    let number: String?
    let artist: String?
    let rarity: String?
    let nationalPokedexNumbers: [Int]?
    let images: CardImages?
}

struct Attack: Codable, Hashable, Sendable {
    let name: String
    let cost: [String]?
    let convertedEnergyCost: Int?
    let damage: String?
    let text: String?
}

struct TypeValue: Codable, Hashable, Sendable {
    let type: String
    let value: String
}

struct CardSet: Codable, Hashable, Sendable {
    let id: String
    let name: String
}

struct CardImages: Codable, Hashable, Sendable {
    let small: String?
    let large: String?

    var smallURL: URL? {
        guard let small else { return nil }
        return URL(string: small)
    }

    var largeURL: URL? {
        guard let large else { return nil }
        return URL(string: large)
    }
}
