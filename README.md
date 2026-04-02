# Gentle-Labs

Small, focused labs that exercise core Swift and iOS engineering skills under realistic constraints.

**Swift 6 · SwiftUI · iOS 17–18 · Tuist · SPM**

---

## Repo Map

| Folder | What's Inside |
|--------|--------------|
| [`01_Concepts`](#01_concepts) | Ranked Q&A sets covering Swift, SwiftUI, concurrency, architecture, and more |
| [`02_Foundations`](#02_foundations) | ListDetail app — the baseline MVVM pattern every other lab builds on |
| [`03_Concurrency`](#03_concurrency) | ImageList app — parallel fetching with `async let` and task groups |
| [`04_Architecture`](#04_architecture) | Clean Architecture, Modular Architecture, and System Design reference notes |
| [`05_Combine`](#05_combine) | 10 Combine operator recipes + an interactive playground |
| [`06_AsyncAlgorithms`](#06_asyncalgorithms) | 10 async/await recipes — modern equivalents of the Combine set |
| [`07_ReviewSheets`](#07_reviewsheets) | Quick-reference cheat sheets for Swift, DSA, and System Design |
| [`08_PatternPractice`](#08_patternpractice) | LeetCode-style syntax katas for high-frequency interview patterns |
| [`10_Prompts`](#10_prompts) | Coding prompts that spec out buildable features from scratch |
| [`11_ProjectDebugging`](#11_projectdebugging) | Fully functional apps with intentional bugs introduced for debugging practice |

---

## Sections

### 01_Concepts

Ranked concept sets (R01–R11) with questions, answers, and lesson notes. Topics progress from broad overviews to focused deep-dives.

<details>
<summary>Topics covered</summary>

- R01 Broad Overview
- R02 Deeper Dives
- R03 Lifecycle
- R04 Probability
- R05 SwiftUI
- R06 Concurrency
- R07 Swift Language
- R08 Architecture
- R09 iOS Platform
- R10 UIKit (Legacy)
- R11 Combine

</details>

### 02_Foundations

A complete **ListDetail** SwiftUI app demonstrating the base pattern used across all labs: protocol-based services, `@Observable` ViewModels, and a generic `ContentLoadingState<T>` enum for loading/error/empty states.

Includes a [Lab Coding Guide](02_Foundations/README.md) that walks through every layer step-by-step.

<details>
<summary>Key patterns</summary>

- `ContentLoadingState` enum (idle → loading → complete/error/empty)
- Protocol-oriented services with Mock, Empty, and Failing variants
- `@MainActor` + `@Observable` ViewModel
- SwiftUI List → Detail navigation with previews

</details>

### 03_Concurrency

An **ImageList** app focused on concurrent image fetching. Demonstrates `async let`, `withThrowingTaskGroup`, task cancellation, and strict `Sendable` conformance under Swift 6.

### 04_Architecture

Reference notes covering three frameworks:

- **Clean Architecture** — Coordinator → View → ViewModel → UseCase → Repository → Services
- **Modular Architecture** — App/Features, Domain, Data, Infra layers
- **System Design** — Requirements, capacity estimation, high-level design, client deep-dives

### 05_Combine

10 standalone Combine recipes, each in its own file with matching unit tests. Plus an interactive playground for experimenting with operator ordering.

<details>
<summary>Recipe list</summary>

1. BasicPublished
2. Map
3. Debounce
4. CombineLatest
5. Filter
6. Subjects
7. Merge
8. FlatMap
9. Timer
10. Networking

</details>

### 06_AsyncAlgorithms

10 async/await recipes that mirror the Combine set, using `AsyncSequence`, `AsyncStream`, and the `swift-async-algorithms` package.

<details>
<summary>Recipe list</summary>

1. Observable
2. Computed
3. Debounce
4. CombineLatest
5. Filter
6. AsyncStream
7. Merge
8. Chaining
9. Timer
10. Networking

</details>

### 07_ReviewSheets

Condensed reference sheets designed for quick review:

- **iOS_DSA** — Swift, iOS, and data structures & algorithms quick-ref
- **SystemDesign** — Request flow, edge layer, database patterns, caching, observability

### 08_PatternPractice

Syntax katas organized by interview probability. Each chunk is a self-contained, compilable snippet you can uncomment and run.

<details>
<summary>Patterns covered</summary>

- Frequency maps, min/max
- Dictionary lookups, two-sum, set-based dedup
- Reverse traversal (stride)
- Sorting (ascending, descending, multi-key)
- Prefix sums, two pointers
- Binary search

</details>

### 10_Prompts

Coding prompts that spec out realistic features — requirements, data flow, and acceptance criteria — so you can build them from scratch.

Currently includes prompts for core product flows (e.g., Store Products List using Protocol-Oriented Programming).

### 11_ProjectDebugging

Fully functional apps with intentional bugs introduced for debugging practice. Each project follows the same MVVM patterns used across the repo.

Currently includes:

- **DisneyCharacters** — SwiftUI app that browses Disney characters with pagination, search, and pull-to-refresh. Includes Network, Mock, Empty, and Failing service variants for previews/testing.

---

## Getting Started

Each lab is a self-contained Tuist project. To open one:

```bash
cd 02_Foundations/ListDetail
tuist generate
open ListDetail.xcodeproj
```

---

## AI-Assisted Content

Some content in this repository was generated with the assistance of large language models. All AI-generated material has been reviewed, edited where necessary, and approved by the repo maintainer.

## License

[MIT](LICENSE)
