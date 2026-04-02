import Foundation

// MARK: - Grouping Category

enum CharacterGrouping: String, CaseIterable, Identifiable {
    case films = "Films"
    case tvShows = "TV Shows"

    var id: String { rawValue }
}

// MARK: - A group of characters sharing a film or show

struct CharacterGroup: Identifiable, Hashable {
    let name: String
    let characterCount: Int

    var id: String { name }
}

// MARK: - Local Character Repository

/// Loads all characters from a bundled JSON file and provides
/// grouped access by films or TV shows.
@MainActor
final class LocalCharacterRepository {

    private var allCharacters: [DisneyCharacter] = []

    /// Characters grouped by film name
    private(set) var filmGroups: [CharacterGroup] = []

    /// Characters grouped by TV show name
    private(set) var tvShowGroups: [CharacterGroup] = []

    /// Lookup: group name -> characters in that group
    private var filmIndex: [String: [DisneyCharacter]] = [:]
    private var tvShowIndex: [String: [DisneyCharacter]] = [:]

    func loadIfNeeded() throws {
        guard allCharacters.isEmpty else { return }

        guard let url = Bundle.main.url(forResource: "all_characters", withExtension: "json") else {
            throw LocalRepositoryError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        allCharacters = try JSONDecoder().decode([DisneyCharacter].self, from: data)

        buildIndex()
    }

    func characters(for groupName: String, grouping: CharacterGrouping) -> [DisneyCharacter] {
        switch grouping {
        case .films:    return filmIndex[groupName] ?? []
        case .tvShows:  return tvShowIndex[groupName] ?? []
        }
    }

    func groups(for grouping: CharacterGrouping) -> [CharacterGroup] {
        switch grouping {
        case .films:    return filmGroups
        case .tvShows:  return tvShowGroups
        }
    }

    // MARK: - Private

    private func buildIndex() {
        var films: [String: [DisneyCharacter]] = [:]
        var shows: [String: [DisneyCharacter]] = [:]

        for character in allCharacters {
            for film in character.films {
                films[film, default: []].append(character)
            }
            for show in character.tvShows {
                shows[show, default: []].append(character)
            }
        }

        filmIndex = films
        tvShowIndex = shows

        filmGroups = films
            .map { CharacterGroup(name: $0.key, characterCount: $0.value.count) }
            .sorted { $0.name < $1.name }

        tvShowGroups = shows
            .map { CharacterGroup(name: $0.key, characterCount: $0.value.count) }
            .sorted { $0.name < $1.name }
    }
}

// MARK: - Errors

enum LocalRepositoryError: LocalizedError {
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Could not find all_characters.json in the app bundle."
        }
    }
}
