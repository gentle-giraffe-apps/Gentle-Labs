// ═══════════════════════════════════════════════════════════
//  ANSWER KEY — do not show during interview
// ═══════════════════════════════════════════════════════════


// ── WARMUP ──
//
// filter keeps evens: 2, 4, 6, 8
// map: 20, 40, 60, 80
// prefix(2): 20, 40
//
// Follow-up: prefix(2) above filter takes [1, 2],
// filter keeps only [2], map → [20]. One value, not two.


// ── PART 1: THE BUG ──
//
// removeDuplicates() runs BEFORE map (lowercased).
// It compares raw strings: "SWIFT" != "swift", so both
// pass through. After map, both become "swift" — duplicate.
//
// Trace:
//   "swift"  → filter ✓ → removeDuplicates (first) ✓ → map "swift"  → results: ["swift"]
//   "swift"  → filter ✓ → removeDuplicates: same     → BLOCKED
//   "SWIFT"  → filter ✓ → removeDuplicates: differs  → map "swift"  → results: ["swift","swift"]
//
// The third assert fails:
//   assert(results == ["swift"])
//   actual: ["swift", "swift"]
//
// Current order:  filter → removeDuplicates → map
// Correct order:  map → filter → removeDuplicates
//
// The fix — move map first:
//
//   query
//       .map { $0.lowercased() }
//       .filter { !$0.isEmpty }
//       .removeDuplicates()
//       .sink { results.append($0) }
//       .store(in: &cancellables)
//
// Now removeDuplicates sees "swift" both times → blocks the dup.
//
// Also: CurrentValueSubject("") emits "" on subscribe.
// The filter catches it — worth asking about if time.
//
// Bonus follow-up: "What if the input had leading spaces too?"
// (They'd need to add .trimmingCharacters to the map.)


// ── PART 2: FUTURE IS EAGER ──
//
// Output when you run:
//   Fetching user 42...          ← prints BEFORE "not yet subscribed"!
//   (created publisher, not yet subscribed)
//   Got: User_42
//   (subscribing again)
//   Got again: User_42           ← no second fetch — Future caches its result
//
// Two problems:
//   1. Future executes its closure IMMEDIATELY on creation,
//      not when a subscriber attaches.
//   2. Future caches the single result and replays it to
//      all future subscribers. It never re-executes.
//
// The fix: wrap Future in Deferred
//
//   let userPublisher = Deferred {
//       Future<String, Error> { promise in
//           fetchUser(id: 42) { result in
//               switch result {
//               case .success(let name): promise(.success(name))
//               case .failure(let err):  promise(.failure(err))
//               }
//           }
//       }
//   }
//
// With Deferred:
//   - The Future is created fresh on each subscription
//   - "Fetching..." only prints when someone subscribes
//   - Each subscriber triggers its own fetch
//
// This is the standard pattern for wrapping callback APIs:
//   Deferred { Future { promise in ... } }


// ═══════════════════════════════════════════════════════════
//  INTERVIEWER NOTES
// ═══════════════════════════════════════════════════════════
//
//  Warmup:
//    - Confidence builder. Move on fast if they get it.
//    - Follow-up: do they think about prefix as limiting
//      what downstream operators see?
//
//  Part 1 (~7 min):
//    - Let them run it and see the assert fail.
//    - The fix: move .map above .removeDuplicates.
//    - If they finish fast, ask: "What if the input had
//      leading spaces too?" (need .trimmingCharacters)
//
//  Part 2 (~10 min):
//    - Key question: WHEN does "Fetching..." print?
//    - If they say "on subscribe" — let them run it and
//      see the surprise. That's the learning moment.
//    - If they know Future is eager — ask them to fix it.
//    - The second subscription is a follow-up: do they
//      notice it doesn't re-fetch? That's the caching
//      behavior of Future (resolves once, replays).
//    - Deferred { Future { } } is the standard fix.
//
//  Bonus questions (if time):
//    - "When would you use Future without Deferred?"
//      (When you WANT eager execution — e.g. fire-and-forget
//       side effects, or when the work is already started)
//    - "What's the async/await equivalent of this pattern?"
//      (Just an async function — no Future/Deferred needed)
//    - "CurrentValueSubject vs PassthroughSubject?"
//      (Initial value, .value property, replays on subscribe)
//
//  Green flags:
//    - Part 1: traces values through operators to find the bug
//    - Part 2: knows Future is eager, or quickly spots it
//    - Mentions Deferred unprompted
//    - Connects it to real-world patterns (API clients, caching)
//
//  Yellow flags:
//    - Part 1: needs a hint to start tracing values
//    - Part 2: surprised by eager execution but figures out Deferred
//
//  Red flags:
//    - Can't reason about operator ordering at all
//    - Doesn't know what Future does
//    - Tries to fix Part 2 by adding .subscribe(on:) or delays
