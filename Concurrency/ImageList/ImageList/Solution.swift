//  Jonathan Ritchey

import Foundation
import Observation
import SwiftUI
import UIKit

@Observable
@MainActor
final class Solution_ImageListViewModel {
    var bannerImage: ImageModel? = nil
    var logoImage: ImageModel? = nil
    var listImages: [ImageModel] = []
    let service: ImageFetchServiceProtocol
    init(service: ImageFetchServiceProtocol) {
        self.service = service
    }
    // MILESTONE 1: Add a method that just fetches the banner image, call it from the view
    func fetchBannerImage() async throws {
        bannerImage = try await service.fetchImage(url: "https://imageService.com/banner.png")
    }
    
    // MILESTONE 2: Change the method in (1) so it fetches the banner and log in parallel
    func fetchBannerAndLogoImages() async throws {
        async let bannerTask = try await service.fetchImage(url: "https://imageService.com/banner.png")
        async let logoTask = try await service.fetchImage(url: "https://imageService.com/logo.png")
        let (bannerImage, logoImage) = try await (bannerTask, logoTask)
        self.bannerImage = bannerImage
        self.logoImage = logoImage
    }
    
    // MILESTONE 3: Fetch a RANDOM number of images (between 5 and 15) IN PARALLEL and assign them to `listImages`.

    func fetchRandomNumberOfImages() async throws {
        let numberOfImages = Int.random(in: 5...15)
        let urls: [String] = (1...numberOfImages).map { _ in "https://imageService.com/random.png" }
        let service = self.service
        let results: [ImageModel] = try await withThrowingTaskGroup(of: ImageModel.self) { group in
            for url in urls {
                group.addTask {
                    try await service.fetchImage(url: url)
                }
            }
            var results: [ImageModel] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
        self.listImages = results
    }
}

struct Solution_ImageList: View {
    @State private var viewModel = Solution_ImageListViewModel(
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
            List(viewModel.listImages, id: \.id) { model in
                if let image = model.asSwiftUIImage() {
                    image
                        .resizable()
                        .frame(width: 120, height: 80)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .task {
            do {
                async let bannerAndLogoTask: () = try await viewModel.fetchBannerAndLogoImages()
                async let imagesTask: () = try await viewModel.fetchRandomNumberOfImages()
                let _ = try await (bannerAndLogoTask, imagesTask)
            } catch {
                print("error \(error)")
            }
        }
    }
}
