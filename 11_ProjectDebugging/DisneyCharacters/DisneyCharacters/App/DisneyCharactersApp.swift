import SwiftUI

@main
struct DisneyCharactersApp: App {
    private let repository = LocalCharacterRepository()

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Characters", systemImage: "person.3") {
                    CharacterListView(
                        viewModel: CharacterListViewModel(service: NetworkCharacterService())
                    )
                }
                Tab("Explore", systemImage: "square.grid.2x2") {
                    ExploreView(
                        viewModel: ExploreViewModel(repository: repository)
                    )
                }
            }
        }
    }
}
