import SwiftUI

@main
struct DisneyCharactersApp: App {
    var body: some Scene {
        WindowGroup {
            CharacterListView(viewModel: CharacterListViewModel(service: NetworkCharacterService()))
        }
    }
}
