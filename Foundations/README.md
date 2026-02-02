# Lab Coding Guide

## General

### Immediate First Steps

1. Create project.
2. Go to the target, select `Build Settings`. Search for `Swift Language Version`. Switch from `Swift 5` to `Swift 6`.
    - Good reasons for choosing Swift 6 include:
        - It enables strict concurrency checks.
        - Surfaces isolation violations early
        - Enforces Sendable across concurrency boundaries.
3. In the ContentView, select Refactor to rename "ContentView" to the landing screen name, i.e. "VisitorsListView".
4. Favor using a single file. Noting:
    - Increasd velocity, while still maintaining separation of concerns.
    - Use the Mark keyword to group things logically so that it's easy to follow.
5. Add a `// MARK: - Model` to start working on the initial model(s) in the project.

### Create the Model and ModelWrapper(if applicable)

1. Add `// Mark: - Model`

```swift
// MARK: - Model

struct Model: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let propertyA: String
    let propertyB: String
    let propertyC: Int
    let imageString: String?
    var image: URL? {
        guard let imageString else { return nil }
        return URL(string: imageString)
    }
    enum CodingKeys: String, CodingKey {
        // user from dummyjson.com
        case id, propertyA = "firstName", propertyB = "lastName", propertyC = "age", imageString = "image"
    }
}

struct ModelWrapper: Codable, Sendable {
    let models: [Model]
    enum CodingKeys: String, CodingKey {
        case models = "users"
    }
}
```

### Implement ModelService Protocol and MockService

```
// MARK: - Service

protocol ModelService: Sendable {
    func fetchModels() async throws -> [Model]
}

struct MockModelService: ModelService {
    let modelCount = 50
    func fetchModels() async throws -> [Model] {
        try await Task.sleep(for: .milliseconds(800))
        return (1...modelCount).map { i in
            .init(
                id: i,
                propertyA: "propertyA \(i)",
                propertyB: "propertyB \(i)",
                propertyC: 3000 + i,
                imageString: "https://picsum.photos/seed/\(i)/600/400"
            )
        }
    }
}

struct EmptyModelService: ModelService {
    func fetchModels() async throws -> [Model] { [] }
}

struct FailingModelService: ModelService {
    func fetchModels() async throws -> [Model] {
        throw URLError(.timedOut)
    }
}

```

### Implement a Generic ContentLoadingState Enum

```swift
// MARK: - View Models

enum ContentLoadingState<T: Equatable>: Equatable {
    case idle
    case loading
    case empty
    case error(String)
    case complete([T])
}
```

### Implement the ViewModel

1. Add `// MARK: - View Models`
1. Annotating the entire view model with @MainActor avoids off-main mutations and reinforces a clear mental model that UI state lives on the main actor. Any heavier or background work goes into use cases or services that run off the main actor and publish their results back.

```swift
// MARK: - View Models

@MainActor
@Observable
final class ModelListViewModel {
    let service: ModelService
    var state: ContentLoadingState<Model> = .idle
    
    @ObservationIgnored
    private var isRefreshing = false
    
    init(
        service: ModelService = MockModelService()
    ) {
        self.service = service
    }
    
    func initialFetch() async {
        guard state == .idle else { return }
        await fetchModels()
    }
    
    func fetchModels() async {
        guard state != .loading && isRefreshing == false else { return }
        defer { isRefreshing = false }
        if state == .idle {
            state = .loading
        } else {
            isRefreshing = true
        }
        do {
            let models = try await service.fetchModels()
            state = models.isEmpty ? .empty : .complete(models)
        } catch {
            state = .error("Something went wrong. Please try again.")
        }
    }
}
```

### Implement the Views

1. Add `// MARK: - Views`

```swift
// MARK: - Views

struct ModelListView: View {
    @State private var viewModel: ModelListViewModel
    
    init(viewModel: ModelListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    ProgressView("Idle…")
                case .loading:
                    ProgressView("Loading…")
                case .complete(let models):
                    List {
                        ForEach(models) { model in
                            NavigationLink {
                                ModelDetail(model: model)
                            } label: {
                                Text(model.propertyA)
                            }
                        }
                    }
                case .empty:
                    ContentUnavailableView("No data yet", systemImage: "tray")
                case .error(let message):
                    ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
                }
            }
            .task {
                await viewModel.initialFetch()
            }
            .refreshable {
                await viewModel.fetchModels()
            }
        }
    }
}
```

### Implement the ModelDetailView

```swift
struct ModelDetail: View {
    let model: Model
    var body: some View {
        ScrollView {
            VStack {
                Text(model.propertyA)
                    .font(.title)
                Text(model.propertyB)
                    .font(.headline)
                Text("\(model.propertyC)")
                    .font(.body)
                if let url = model.image {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 200)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 32,
                                        style: .continuous
                                    )
                                )
                                .clipped()
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                        default:
                            ProgressView()
                        }
                    }
                }
            }
        }
    }
}
```

### Implement Previews

```swift
// MARK: - Previews

#Preview("List Mock") {
    ModelListView(viewModel: ModelListViewModel())
}

#Preview("List Mock Empty") {
    ModelListView(viewModel: ModelListViewModel(service: EmptyModelService()))
}

#Preview("List Mock Failing") {
    ModelListView(viewModel: ModelListViewModel(service: FailingModelService()))
}

// #Preview("List Live") {
//     ModelListView(viewModel: ModelListViewModel(service: NetworkModelService()))
// }

#Preview ("Detail") {
    ModelDetail(model: Model(id: 1, propertyA: "propertyA", propertyB: "propertyB", propertyC: 30, imageString: "https://picsum.photos/seed/123/600/400"))
}

```

