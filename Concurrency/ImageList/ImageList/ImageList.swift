//  Jonathan Ritchey

import SwiftUI
import Observation

// Put all code here
struct ImageModel: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let url: String
    let imageData: Data
}

protocol ImageFetchServiceProtocol {
    func fetchImage(url: String) async throws -> ImageModel
}

struct ImageFetchServiceMock: ImageFetchServiceProtocol {
    func fetchImage(url: String) async throws -> ImageModel {
        
    }
}

@Observable
final class ImageListViewModel {
    var bannerImage: ImageModel? = nil
    var logoImage: ImageModel? = nil
    var listImages: [ImageModel] = []
}

struct ImageList: View {
    @State private var viewModel = ImageListViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ImageList()
}
