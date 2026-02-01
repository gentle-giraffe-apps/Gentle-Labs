//  Jonathan Ritchey

import Observation
import SwiftUI
import UIKit

// TaskGroup (dynamic number of tasks)
//
// await withTaskGroup(of: ResultType.self) { group in
//     for item in items {
//         group.addTask {
//             await someAsyncCall(item)
//         }
//     }
//
//     for await result in group {
//         // collect results
//     }
// }

struct ImageModel: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let url: String
    let imageData: Data
    
    func asSwiftUIImage() -> Image? {
        guard let uiImage = UIImage(data: imageData) else { return nil }
        return Image(uiImage: uiImage)
    }
}

protocol ImageFetchServiceProtocol: Sendable {
    func fetchImage(url: String) async throws -> ImageModel
}

struct ImageFetchServiceMock: ImageFetchServiceProtocol, Sendable {
    func fetchImage(url: String) async throws -> ImageModel {
        // Simulate latency
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        try Task.checkCancellation()
        return ImageModel(
            id: UUID().uuidString,
            url: url,
            imageData: try randomSystemImageData()
        )
    }
    
    private let systemImageNames = [
        "star.fill",
        "heart.fill",
        "bolt.fill",
        "globe",
        "flame.fill",
        "leaf.fill",
        "moon.fill",
        "sun.max.fill",
        "cloud.fill",
        "paperplane.fill"
    ]

    enum ImageGenerationError: Error {
        case noSystemImageAvailable
        case imageConfigurationFailed
        case pngEncodingFailed
    }
    
    func randomSystemImageData() throws -> Data {
        let config = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular)
        guard let name = systemImageNames.randomElement() else {
            throw ImageGenerationError.noSystemImageAvailable
        }
        guard let image = UIImage(systemName: name) else {
            throw ImageGenerationError.imageConfigurationFailed
        }
        guard let configuredImage = image.applyingSymbolConfiguration(config) else {
            throw ImageGenerationError.imageConfigurationFailed
        }
        guard let data = configuredImage.pngData() else {
            throw ImageGenerationError.pngEncodingFailed
        }
        return data
    }
}

@Observable
@MainActor
final class ImageListViewModel {
    var bannerImage: ImageModel? = nil
    var logoImage: ImageModel? = nil
    var listImages: [ImageModel] = []
    let service: ImageFetchServiceProtocol
    init(service: ImageFetchServiceProtocol) {
        self.service = service
    }
    // MILESTONE 1: Add a method that just fetches the banner image, call it from the view
    
    // MILESTONE 2: Change the method in (1) so it fetches the banner and log in parallel
    
    // Syntax:
    // async let (fixed, small number of tasks)
    //
    // async let a = someAsyncCall()
    // async let b = someAsyncCall()
    // let result = try await (a, b)

    
    // MILESTONE 3: Fetch a RANDOM number of images (between 5 and 15) IN PARALLEL and assign them to `listImages`.

    // Syntax:
    // TaskGroup (dynamic number of tasks)
    //
    // await withTaskGroup(of: ResultType.self) { group in
    //     for item in items {
    //         group.addTask {
    //             await someAsyncCall(item)
    //         }
    //     }
    //
    //     for await result in group {
    //         // collect results
    //     }
    // }
}

struct ImageList: View {
    @State private var viewModel = ImageListViewModel(
        service: ImageFetchServiceMock()
    )
    
    var body: some View {
        VStack {
            if let bannerImage = viewModel.bannerImage?.asSwiftUIImage() {
                bannerImage
                    .resizable()
                    .frame(width: 120, height: 80)
                    .cornerRadius(12)
            }
            if let logoImage = viewModel.logoImage?.asSwiftUIImage() {
                logoImage
                    .resizable()
                    .frame(width: 120, height: 80)
                    .cornerRadius(12)
            }
            List(viewModel.listImages) { model in
                if let image = model.asSwiftUIImage() {
                    image
                        .resizable()
                        .frame(width: 120, height: 80)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ImageList()
}
