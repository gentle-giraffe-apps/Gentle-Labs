import Foundation

// MARK: - Explore ViewModel

@MainActor
@Observable
final class ExploreViewModel {

    // MARK: - Dependencies

    let repository: LocalCharacterRepository

    // MARK: - State

    private(set) var state: ContentLoadingState = .initial
    var selectedGrouping: CharacterGrouping = .films
    var searchText: String = ""

    // MARK: - Init

    init(repository: LocalCharacterRepository) {
        self.repository = repository
    }

    // MARK: - Computed

    var groups: [CharacterGroup] {
        let all = repository.groups(for: selectedGrouping)
        if searchText.isEmpty {
            return all
        }
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func characters(for group: CharacterGroup) -> [DisneyCharacter] {
        repository.characters(for: group.name, grouping: selectedGrouping)
    }

    // MARK: - Loading

    func load() {
        guard state == .initial else { return }
        do {
            try repository.loadIfNeeded()
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
