// LEETCODE SYNTAX KATA v1
// Goal: type each chunk from memory until it feels automatic.
// Each chunk compiles and runs if you uncomment it.

// ==================================================
// TIER 1 — HIGHEST PROBABILITY
// ==================================================

// CHUNK 1: Frequency Map + Min/Max
// Concepts: dictionary default subscript, min/max tracking, for-in loop

// do {
//     var numbers = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3]
//
//     var freq = [Int: Int]()
//     var maximum = Int.min
//     var minimum = Int.max
//
//     for n in numbers {
//         freq[n, default: 0] += 1
//         maximum = max(maximum, n)
//         minimum = min(minimum, n)
//     }
//
//     print("freq:", freq)
//     print("min:", minimum, "max:", maximum)
//
//     Move all 3's to the end in-place.
//     Idea: Scan left-to-right. Anything illegal(non-three), swap and advance boundary.
//     Invariant: 1..<boundary..<scan is correctly partitioned.
//     var boundary = 0
//     for scan in 0..<numbers.count {
//         if numbers[scan] != 3 {
//            numbers.swapAt(scan, boundary)
//            boundary += 1
//         }
//     }
// }

// CHUNK 2: If-Let Dictionary + Two-Sum + Set Duplicate Detection
// Concepts: if-let unwrap from dict, value-to-index map, set contains/insert

// do {
//     let nums = [2, 7, 11, 2, 15]
//     let target = 9
//
//     var seen = [Int: Int]()   // value -> index (for two-sum)
//     var uniques = Set<Int>()  // for duplicate detection
//
//     for (i, x) in nums.enumerated() {
//         // two-sum: check complement in dictionary
//         let complement = target - x
//         if let j = seen[complement] {
//             print("two-sum indices:", j, i)
//         }
//         seen[x] = i
//
//         // duplicate detection via set
//         if !uniques.insert(x).inserted {
//             print("duplicate:", x, "at index", i)
//         }
//     }
// }

// CHUNK 3: Reverse Traversal
// Concepts: stride(from:through:by:)

// do {
//     let nums = [1, 2, 3, 4, 5]
//
//     for i in stride(from: nums.count - 1, through: 0, by: -1) {
//         print("reverse[\(i)]:", nums[i])
//     }
// }

// CHUNK 4: Sorting
// Concepts: sorted(), sorted(by:), custom multi-key sort

// do {
//     let nums = [5, 3, 8, 1, 9, 2]
//     let ascending = nums.sorted()
//     let descending = nums.sorted(by: >)
//     print("asc:", ascending)
//     print("desc:", descending)
//
//     let intervals = [[1, 3], [2, 6], [1, 2], [8, 10]]
//     let sorted = intervals.sorted {
//         if $0[0] == $1[0] {
//             return $0[1] < $1[1]
//         }
//         return $0[0] < $1[0]
//     }
//     print("sorted intervals:", sorted)
// }

// CHUNK 5: Prefix Sum + Two Pointers
// Concepts: prefix sum array, range sum query, sorted two-pointer search

// do {
//     let nums = [1, 2, 3, 4, 5, 6]
//
//     // prefix sum
//     var prefix = Array(repeating: 0, count: nums.count + 1)
//     for i in 0..<nums.count {
//         prefix[i + 1] = prefix[i] + nums[i]
//     }
//     // sum of range [1...3] = prefix[4] - prefix[1]
//     print("prefix:", prefix)
//     print("sum [1...3]:", prefix[4] - prefix[1])
//
//     // two pointers on sorted array
//     let sorted = nums.sorted()
//     let target = 7
//     var left = 0
//     var right = sorted.count - 1
//
//     while left < right {
//         let s = sorted[left] + sorted[right]
//         if s == target {
//             print("pair:", sorted[left], sorted[right])
//             break
//         } else if s < target {
//             left += 1
//         } else {
//             right -= 1
//         }
//     }
// }

// CHUNK 6: Sliding Window
// Concepts: expand/shrink window, frequency map in window, longest substring

// do {
//     // max sum of subarray of size k
//     let nums = [2, 1, 5, 1, 3, 2]
//     let k = 3
//     var windowSum = 0
//     var best = 0
//
//     for right in 0..<nums.count {
//         windowSum += nums[right]
//
//         if right >= k {
//             windowSum -= nums[right - k]
//         }
//
//         if right >= k - 1 {
//             best = max(best, windowSum)
//         }
//     }
//     print("max window sum (k=\(k)):", best)
//
//     // longest substring with at most 2 distinct chars
//     let s = "eceba"
//     let chars = Array(s)
//     var left = 0
//     var count: [Character: Int] = [:]
//     var longest = 0
//
//     for right in 0..<chars.count {
//         count[chars[right], default: 0] += 1
//
//         while count.count > 2 {
//             count[chars[left]]! -= 1
//             if count[chars[left]] == 0 {
//                 count.removeValue(forKey: chars[left])
//             }
//             left += 1
//         }
//
//         longest = max(longest, right - left + 1)
//     }
//     print("longest substring (2 distinct):", longest)
// }

// ==================================================
// TIER 2 — VERY HIGH PROBABILITY
// ==================================================

// CHUNK 7: Binary Search
// Concepts: exact match, lower bound, answer-space search

// do {
//     let nums = [1, 3, 5, 7, 9, 11, 13]
//
//     // exact match
//     func binarySearch(_ nums: [Int], _ target: Int) -> Int {
//         var left = 0
//         var right = nums.count - 1
//
//         while left <= right {
//             let mid = left + (right - left) / 2
//             if nums[mid] == target {
//                 return mid
//             } else if nums[mid] < target {
//                 left = mid + 1
//             } else {
//                 right = mid - 1
//             }
//         }
//         return -1
//     }
//     print("find 7:", binarySearch(nums, 7))
//
//     // lower bound (first index where nums[i] >= target)
//     func lowerBound(_ nums: [Int], _ target: Int) -> Int {
//         var left = 0
//         var right = nums.count
//
//         while left < right {
//             let mid = left + (right - left) / 2
//             if nums[mid] < target {
//                 left = mid + 1
//             } else {
//                 right = mid
//             }
//         }
//         return left
//     }
//     print("lower bound of 6:", lowerBound(nums, 6))
//
//     // answer-space binary search (e.g., "min capacity to ship in D days")
//     func canShip(_ weights: [Int], _ capacity: Int, _ days: Int) -> Bool {
//         var d = 1, load = 0
//         for w in weights {
//             if load + w > capacity { d += 1; load = 0 }
//             load += w
//         }
//         return d <= days
//     }
//
//     let weights = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
//     let days = 5
//     var lo = weights.max()!
//     var hi = weights.reduce(0, +)
//
//     while lo < hi {
//         let mid = lo + (hi - lo) / 2
//         if canShip(weights, mid, days) {
//             hi = mid
//         } else {
//             lo = mid + 1
//         }
//     }
//     print("min ship capacity:", lo)
// }

// CHUNK 8: Monotonic Stack + Interval Merge
// Concepts: next-greater-element stack, sorting + greedy merge

// do {
//     // monotonic stack: next greater element
//     let nums = [2, 1, 2, 4, 3]
//     var result = Array(repeating: -1, count: nums.count)
//     var stack: [Int] = []  // indices
//
//     for i in 0..<nums.count {
//         while let last = stack.last, nums[last] < nums[i] {
//             result[stack.removeLast()] = nums[i]
//         }
//         stack.append(i)
//     }
//     print("next greater:", result)
//
//     // interval merge
//     var intervals = [[1, 3], [2, 6], [8, 10], [15, 18]]
//     intervals.sort { $0[0] < $1[0] }
//     var merged: [[Int]] = []
//
//     for interval in intervals {
//         if merged.isEmpty || merged[merged.count - 1][1] < interval[0] {
//             merged.append(interval)
//         } else {
//             merged[merged.count - 1][1] = max(merged[merged.count - 1][1], interval[1])
//         }
//     }
//     print("merged:", merged)
// }

// CHUNK 9: BFS Grid + BFS Level Order
// Concepts: queue-as-array BFS, visited set, 4-directional movement, level counting

// do {
//     // BFS on grid (flood fill / shortest path)
//     let grid = [
//         [1, 1, 0, 0],
//         [1, 1, 0, 1],
//         [0, 0, 0, 1],
//         [0, 0, 1, 1]
//     ]
//     let rows = grid.count, cols = grid[0].count
//     let sr = 0, sc = 0
//
//     var queue: [(Int, Int)] = [(sr, sc)]
//     var index = 0
//     var visited: Set<[Int]> = [[sr, sc]]
//
//     while index < queue.count {
//         let (r, c) = queue[index]
//         index += 1
//
//         for (dr, dc) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
//             let nr = r + dr
//             let nc = c + dc
//             let key = [nr, nc]
//
//             if nr >= 0, nr < rows, nc >= 0, nc < cols,
//                grid[nr][nc] == 1,
//                !visited.contains(key) {
//                 visited.insert(key)
//                 queue.append((nr, nc))
//             }
//         }
//     }
//     print("BFS visited \(visited.count) cells")
//
//     // BFS level order (simulated tree with adjacency list)
//     let adj: [Int: [Int]] = [0: [1, 2], 1: [3, 4], 2: [5], 3: [], 4: [], 5: []]
//     var levelQueue = [0]
//     var li = 0
//     var level = 0
//
//     while li < levelQueue.count {
//         let levelCount = levelQueue.count - li
//         print("level \(level):", levelQueue[li..<(li + levelCount)].map { $0 })
//         for _ in 0..<levelCount {
//             let node = levelQueue[li]
//             li += 1
//             for child in adj[node, default: []] {
//                 levelQueue.append(child)
//             }
//         }
//         level += 1
//     }
// }

// CHUNK 10: DFS Grid + Backtracking
// Concepts: recursive grid DFS, marking visited, generating combinations

// do {
//     // DFS grid: count connected components (island count)
//     var grid: [[Character]] = [
//         ["1", "1", "0", "0"],
//         ["1", "0", "0", "1"],
//         ["0", "0", "1", "1"],
//     ]
//     let rows = grid.count, cols = grid[0].count
//
//     func dfs(_ r: Int, _ c: Int) {
//         guard r >= 0, r < rows, c >= 0, c < cols else { return }
//         guard grid[r][c] == "1" else { return }
//         grid[r][c] = "0"  // mark visited
//         dfs(r + 1, c)
//         dfs(r - 1, c)
//         dfs(r, c + 1)
//         dfs(r, c - 1)
//     }
//
//     var islands = 0
//     for r in 0..<rows {
//         for c in 0..<cols {
//             if grid[r][c] == "1" {
//                 islands += 1
//                 dfs(r, c)
//             }
//         }
//     }
//     print("islands:", islands)
//
//     // backtracking: all subsets
//     let nums = [1, 2, 3]
//     var result: [[Int]] = []
//     var path: [Int] = []
//
//     func backtrack(_ start: Int) {
//         result.append(path)
//         for i in start..<nums.count {
//             path.append(nums[i])
//             backtrack(i + 1)
//             path.removeLast()
//         }
//     }
//
//     backtrack(0)
//     print("subsets:", result)
// }

// ==================================================
// TIER 3 — COMMON SENIOR-LEVEL PATTERNS
// ==================================================

// CHUNK 11: Dynamic Programming (Memo + Bottom-Up + 2D)
// Concepts: top-down memo, bottom-up tabulation, 2D grid DP

// do {
//     let n = 10
//
//     // memoized DFS (fibonacci)
//     var memo: [Int: Int] = [:]
//     func fib(_ i: Int) -> Int {
//         if i <= 1 { return i }
//         if let cached = memo[i] { return cached }
//         let ans = fib(i - 1) + fib(i - 2)
//         memo[i] = ans
//         return ans
//     }
//     print("fib(\(n)) memo:", fib(n))
//
//     // bottom-up DP (fibonacci)
//     var dp = Array(repeating: 0, count: n + 1)
//     dp[0] = 0
//     dp[1] = 1
//     if n >= 2 {
//         for i in 2...n {
//             dp[i] = dp[i - 1] + dp[i - 2]
//         }
//     }
//     print("fib(\(n)) bottom-up:", dp[n])
//
//     // 2D DP: unique paths in grid
//     let rows = 3, cols = 4
//     var grid = Array(repeating: Array(repeating: 0, count: cols), count: rows)
//
//     for r in 0..<rows { grid[r][0] = 1 }
//     for c in 0..<cols { grid[0][c] = 1 }
//
//     for r in 1..<rows {
//         for c in 1..<cols {
//             grid[r][c] = grid[r - 1][c] + grid[r][c - 1]
//         }
//     }
//     print("unique paths \(rows)x\(cols):", grid[rows - 1][cols - 1])
// }

// CHUNK 12: Graph — Adjacency List + Topo Sort + Matrix Traversal
// Concepts: build graph, indegree array, Kahn's BFS topo sort, grid iteration

// do {
//     let n = 6
//     let edges = [[0, 1], [0, 2], [1, 3], [2, 3], [3, 4], [4, 5]]
//
//     // build adjacency list
//     var graph = Array(repeating: [Int](), count: n)
//     var indegree = Array(repeating: 0, count: n)
//
//     for edge in edges {
//         let u = edge[0], v = edge[1]
//         graph[u].append(v)
//         indegree[v] += 1
//     }
//
//     // Kahn's algorithm (BFS topo sort)
//     var queue = (0..<n).filter { indegree[$0] == 0 }
//     var idx = 0
//     var order: [Int] = []
//
//     while idx < queue.count {
//         let u = queue[idx]
//         idx += 1
//         order.append(u)
//
//         for v in graph[u] {
//             indegree[v] -= 1
//             if indegree[v] == 0 {
//                 queue.append(v)
//             }
//         }
//     }
//     print("topo order:", order)
//
//     // matrix traversal + boundary check
//     let grid = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
//     let rows = grid.count, cols = grid[0].count
//
//     func isValid(_ r: Int, _ c: Int) -> Bool {
//         r >= 0 && r < rows && c >= 0 && c < cols
//     }
//
//     for r in 0..<rows {
//         for c in 0..<cols {
//             print(grid[r][c], terminator: isValid(r, c + 1) ? " " : "\n")
//         }
//     }
// }

// CHUNK 13: Linked List — Reversal + Fast/Slow
// Concepts: ListNode class, in-place reversal, cycle detection / find middle

// do {
//     class ListNode {
//         var val: Int
//         var next: ListNode?
//         init(_ val: Int, _ next: ListNode? = nil) {
//             self.val = val
//             self.next = next
//         }
//     }
//
//     func printList(_ head: ListNode?) {
//         var curr = head
//         var vals: [Int] = []
//         while let node = curr { vals.append(node.val); curr = node.next }
//         print(vals)
//     }
//
//     // build: 1 -> 2 -> 3 -> 4 -> 5
//     let head = ListNode(1, ListNode(2, ListNode(3, ListNode(4, ListNode(5)))))
//
//     // reverse linked list
//     var prev: ListNode? = nil
//     var curr: ListNode? = head
//
//     while curr != nil {
//         let next = curr?.next
//         curr?.next = prev
//         prev = curr
//         curr = next
//     }
//     print("reversed:")
//     printList(prev)
//
//     // fast and slow pointer (find middle)
//     var slow = prev
//     var fast = prev
//
//     while fast != nil && fast?.next != nil {
//         slow = slow?.next
//         fast = fast?.next?.next
//     }
//     print("middle value:", slow?.val ?? -1)
// }

// CHUNK 14: Heap (Min-Heap via Sorted Array) + Top-K
// Concepts: sorted-array heap, insert/extract, top-K pattern

// do {
//     let nums = [3, 1, 5, 12, 2, 11]
//     let k = 3
//
//     var minHeap: [Int] = []
//
//     func heapInsert(_ val: Int) {
//         minHeap.append(val)
//         minHeap.sort()
//     }
//
//     func heapExtractMin() -> Int? {
//         minHeap.isEmpty ? nil : minHeap.removeFirst()
//     }
//
//     // top K largest: maintain min-heap of size K
//     for x in nums {
//         heapInsert(x)
//         if minHeap.count > k {
//             _ = heapExtractMin()
//         }
//     }
//     print("top \(k) largest:", minHeap)
//     print("kth largest:", minHeap.first ?? -1)
// }

// CHUNK 15: Union-Find
// Concepts: path compression, union by rank, connected components

// do {
//     let n = 7
//     let connections = [[0, 1], [1, 2], [3, 4], [5, 6], [4, 5]]
//
//     var parent = Array(0..<n)
//     var rank = Array(repeating: 0, count: n)
//
//     func find(_ x: Int) -> Int {
//         if parent[x] != x {
//             parent[x] = find(parent[x])
//         }
//         return parent[x]
//     }
//
//     func union(_ x: Int, _ y: Int) {
//         let px = find(x), py = find(y)
//         if px == py { return }
//         if rank[px] < rank[py] {
//             parent[px] = py
//         } else if rank[px] > rank[py] {
//             parent[py] = px
//         } else {
//             parent[py] = px
//             rank[px] += 1
//         }
//     }
//
//     for conn in connections {
//         union(conn[0], conn[1])
//     }
//
//     let components = Set((0..<n).map { find($0) }).count
//     print("connected components:", components)
// }

// ==================================================
// MICRO-KATA RULES
// ==================================================
//
// Round 1: Chunks 1-6   (Tier 1 fundamentals)
// Round 2: Chunks 7-10  (Tier 2 algorithms)
// Round 3: Chunks 11-15 (Tier 3 advanced)
// Round 4: All chunks from memory (no peeking)
// Round 5: For each chunk, name 2 LeetCode problems it solves
// Round 6: Given a problem, identify which 2-3 chunks to combine

// ==================================================
// MAPPING: WHAT TO THINK WHEN YOU SEE THE PROMPT
// ==================================================
//
// array/string + pair + sorted            -> two pointers (chunk 5)
// array/string + longest/shortest subarray -> sliding window (chunk 6)
// lookup/count/frequency                  -> dictionary or set (chunks 1-2)
// sorted + find boundary/value            -> binary search (chunk 7)
// tree level order                        -> BFS (chunk 9)
// grid shortest path                      -> BFS (chunk 9)
// grid connected components               -> DFS (chunk 10)
// overlapping ranges                      -> interval merge (chunk 8)
// choices/combinations/permutations       -> backtracking (chunk 10)
// optimal substructure / min steps        -> DP (chunk 11)
// dependency order                        -> topo sort (chunk 12)
// next greater / monotonic behavior       -> stack (chunk 8)
// cycle / middle of linked list           -> fast & slow (chunk 13)
// top K / repeated min extraction         -> heap (chunk 14)
// connected components / redundant edges  -> union-find (chunk 15)
