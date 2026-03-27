import SwiftUI

@main
struct PokemonTCGApp: App {
    var body: some Scene {
        WindowGroup {
            CardListView(viewModel: CardListViewModel(service: NetworkCardService()))
        }
    }
}
