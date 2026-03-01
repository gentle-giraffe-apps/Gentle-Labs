import Combine
import Foundation

// ═══════════════════════════════════════════════════════════
//  Combine — Mock Interview  (~20 min)
// ═══════════════════════════════════════════════════════════
//
//  New iOS code uses async/await and @Observable, but most
//  production codebases still have Combine pipelines.
//  Interviews test whether you can READ and DEBUG existing
//  Combine code — not write it from scratch.
//
//  Warmup — Predict the output              (~3 min)
//  Part 1 — Find and fix a pipeline bug     (~7 min)
//  Part 2 — Future                          (~10 min)
// ═══════════════════════════════════════════════════════════


// ─────────────────────────────────────────────────────────
// Combine Cheat Sheet — the core types
// ─────────────────────────────────────────────────────────
//
// PassthroughSubject<Value, Error>
//   A publisher YOU send values to. No stored state —
//   if nobody is subscribed, sent values are lost.
//
//   let tap = PassthroughSubject<String, Never>()
//   tap.sink { print($0) }
//   tap.send("hello")  // prints "hello"
//
// CurrentValueSubject<Value, Error>
//   Like PassthroughSubject but holds the latest value.
//   New subscribers immediately get the current value.
//   Access it anytime via .value.
//
//   let score = CurrentValueSubject<Int, Never>(0)
//   score.sink { print($0) }  // prints 0 immediately
//   score.send(10)             // prints 10
//   print(score.value)         // 10
//
// Future<Value, Error>
//   A publisher that runs a closure and emits exactly
//   ONE value (or error), then completes. Used to bridge
//   callback APIs into Combine.
//
//   let f = Future<String, Error> { promise in
//       promise(.success("done"))
//   }
//   f.sink(receiveCompletion: { _ in },
//          receiveValue: { print($0) })  // "done"
//
// Deferred<Publisher>
//   Wraps a publisher factory. The inner publisher isn't
//   created until someone subscribes. Each subscriber
//   gets a fresh instance.
//
//   let d = Deferred { Just("lazy") }
//   // nothing happens yet
//   d.sink { print($0) }  // NOW "lazy" prints
//
// AnyCancellable
//   A token returned by .sink(). When it's deallocated
//   the subscription is cancelled. Store them in a
//   Set<AnyCancellable> to keep subscriptions alive.
//
//   var cancellables = Set<AnyCancellable>()
//   subject.sink { print($0) }
//       .store(in: &cancellables)
//
// ─────────────────────────────────────────────────────────

var cancellables = Set<AnyCancellable>()


// ─────────────────────────────────────────────────────────
// WARMUP: Predict the Output  (~3 min)
// ─────────────────────────────────────────────────────────
// Read this pipeline and predict what prints BEFORE you run.

print("── Warmup ──")
[1, 2, 3, 4, 5, 6, 7, 8]
    .publisher
    .filter { $0 % 2 == 0 }           // keep evens
    .map { $0 * 10 }                   // multiply by 10
    .prefix(2)                         // take first 2
    .sink { print($0) }
    .store(in: &cancellables)

// Follow-up: what if you moved prefix(2) ABOVE filter?
// (Reason about it — don't run.)


// ─────────────────────────────────────────────────────────
// PART 1: Search pipeline  (~7 min)
// ─────────────────────────────────────────────────────────
// You inherited this search pipeline. It should normalize
// input and skip duplicates, but there's a bug in prod.
//
// 1. Read the code
// 2. Run it — one assert fails
// 3. Fix the pipeline so all asserts pass

print("\n── Part 1 ──")

let query = CurrentValueSubject<String, Never>("")
var results: [String] = []

query
    .filter { !$0.isEmpty }
    .removeDuplicates()
    .map { $0.lowercased() }
    .sink { results.append($0) }
    .store(in: &cancellables)

// ── Scenario: user types in a search bar ────────────────

query.send("swift")
assert(results == ["swift"], "basic search: got \(results)")

query.send("swift")
assert(results == ["swift"], "exact dup skipped: got \(results)")

query.send("SWIFT")
// Same word — autocorrect capitalized it. Should still be ["swift"].
assert(results == ["swift"], "case dup skipped: got \(results)")

query.send("combine")
assert(results == ["swift", "combine"], "new term added: got \(results)")

print("Part 1 passed!")


// ─────────────────────────────────────────────────────────
// PART 2: Future  (~10 min)
// ─────────────────────────────────────────────────────────
// A teammate wrapped a callback API in a Future, but
// it's firing at the wrong time.
//
// 1. Read the code and predict when "Fetching..." prints
// 2. Run it — check if you're right
// 3. Fix the problem

print("\n── Part 2 ──")

// Simulates a network call
func fetchUser(id: Int, completion: @escaping (Result<String, Error>) -> Void) {
    print("  Fetching user \(id)...")
    completion(.success("User_\(id)"))
}

// Wrap the callback API in Combine
let userPublisher = Future<String, Error> { promise in
    fetchUser(id: 42) { result in
        switch result {
        case .success(let name): promise(.success(name))
        case .failure(let err):  promise(.failure(err))
        }
    }
}

// Q: Does "Fetching user 42..." print now, or only when we subscribe?
print("  (created publisher, not yet subscribed)")

// Subscribe
userPublisher
    .sink(
        receiveCompletion: { _ in },
        receiveValue: { print("  Got: \($0)") }
    )
    .store(in: &cancellables)

// Q: If we subscribe a SECOND time, does it fetch again?
print("  (subscribing again)")
userPublisher
    .sink(
        receiveCompletion: { _ in },
        receiveValue: { print("  Got again: \($0)") }
    )
    .store(in: &cancellables)

// TODO: Fix userPublisher so that:
//   1. The fetch only runs when someone subscribes (not on creation)
//   2. Each new subscriber triggers its own fetch
//
// Hint: there's a Combine wrapper that makes a publisher lazy.

print("\nDone!")
