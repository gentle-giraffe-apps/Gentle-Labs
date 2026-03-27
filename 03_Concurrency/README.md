# 03_Concurrency

An **ImageList** app focused on concurrent image fetching. Demonstrates `async let`, `withThrowingTaskGroup`, task cancellation, and strict `Sendable` conformance under Swift 6.

## Key Patterns

- **`async let`** — parallel fetching of banner and logo images
- **`withThrowingTaskGroup`** — dynamic parallel fetching of a variable number of images
- **`Task.checkCancellation()`** — cooperative cancellation support
- **`Sendable`** — all models and services conform to `Sendable`
- **`@MainActor` + `@Observable`** — ViewModel isolation

The project includes both an exercise scaffold (`ImageList.swift`) and a complete solution (`Solution.swift`).

## Getting Started

This lab uses Tuist. To open it:

```bash
cd ImageList
tuist generate
open ImageList.xcodeproj
```
