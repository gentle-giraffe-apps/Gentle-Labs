// LEETCODE SYNTAX KATA v1
// Goal: type this from memory in CoderPad until it feels automatic.

// ==================================================
// TIER 1 — HIGHEST PROBABILITY
// ==================================================

// 1) for loop over array
// for i in 0..<nums.count {
//     let x = nums[i]
// }

// 2) for with enumerate-ish index + value
// for (i, x) in nums.enumerated() {
// }

// 3) guard early return
// guard !nums.isEmpty else { return 0 }

// 4) if let from dictionary
// if let count = freq[x] {
//     freq[x] = count + 1
// } else {
//     freq[x] = 1
// }

// 5) dictionary increment shortcut
// freq[x, default: 0] += 1

// 6) set insert / contains
// var seen = Set<Int>()
// if seen.contains(x) {
// }
// seen.insert(x)

// 7) min / max update
// best = min(best, candidate)
// best = max(best, candidate)

// 8) running sum
// var sum = 0
// for x in nums {
//     sum += x
// }

// 9) prefix sum style
// var prefix = Array(repeating: 0, count: nums.count + 1)
// for i in 0..<nums.count {
//     prefix[i + 1] = prefix[i] + nums[i]
// }

// 10) classic two pointers
// var left = 0
// var right = nums.count - 1
// while left < right {
//     let s = nums[left] + nums[right]
//     if s == target {
//         break
//     } else if s < target {
//         left += 1
//     } else {
//         right -= 1
//     }
// }

// 11) sliding window expand / shrink
// var left = 0
// for right in 0..<nums.count {
//     // add nums[right]
//
//     while /* window invalid */ {
//         // remove nums[left]
//         left += 1
//     }
//
//     // update answer
// }

// 12) sliding window with frequency map
// var left = 0
// var count: [Character: Int] = [:]
// let chars = Array(s)
//
// for right in 0..<chars.count {
//     count[chars[right], default: 0] += 1
//
//     while /* invalid */ {
//         count[chars[left]]! -= 1
//         if count[chars[left]] == 0 {
//             count.removeValue(forKey: chars[left])
//         }
//         left += 1
//     }
//
//     // best = max(best, right - left + 1)
// }

// 13) reverse array/string traversal
// for i in stride(from: nums.count - 1, through: 0, by: -1) {
//     let x = nums[i]
// }

// 14) sort ascending / descending
// let a = nums.sorted()
// let b = nums.sorted(by: >)

// 15) custom sort
// let pairs = intervals.sorted {
//     if $0[0] == $1[0] {
//         return $0[1] < $1[1]
//     }
//     return $0[0] < $1[0]
// }

// ==================================================
// TIER 2 — VERY HIGH PROBABILITY
// ==================================================

// 16) binary search exact
// var left = 0
// var right = nums.count - 1
//
// while left <= right {
//     let mid = left + (right - left) / 2
//     if nums[mid] == target {
//         return mid
//     } else if nums[mid] < target {
//         left = mid + 1
//     } else {
//         right = mid - 1
//     }
// }
// return -1

// 17) binary search lower bound
// var left = 0
// var right = nums.count
//
// while left < right {
//     let mid = left + (right - left) / 2
//     if nums[mid] < target {
//         left = mid + 1
//     } else {
//         right = mid
//     }
// }
// // left is insertion point

// 18) monotonic answer-space binary search
// var left = 1
// var right = 1_000_000_000
//
// while left < right {
//     let mid = left + (right - left) / 2
//     if can(mid) {
//         right = mid
//     } else {
//         left = mid + 1
//     }
// }
// return left

// 19) stack usage
// var stack: [Int] = []
// for x in nums {
//     while let last = stack.last, last < x {
//         stack.removeLast()
//     }
//     stack.append(x)
// }

// 20) queue BFS with index
// var queue: [(Int, Int)] = [(sr, sc)]
// var index = 0
// var visited: Set<[Int]> = [[sr, sc]]
//
// while index < queue.count {
//     let (r, c) = queue[index]
//     index += 1
//
//     for (dr, dc) in [(1,0), (-1,0), (0,1), (0,-1)] {
//         let nr = r + dr
//         let nc = c + dc
//         let key = [nr, nc]
//
//         if nr >= 0, nr < rows, nc >= 0, nc < cols,
//            grid[nr][nc] == 1,
//            !visited.contains(key) {
//             visited.insert(key)
//             queue.append((nr, nc))
//         }
//     }
// }

// 21) BFS level order
// var queue: [TreeNode] = [root]
// var index = 0
//
// while index < queue.count {
//     let levelCount = queue.count - index
//     for _ in 0..<levelCount {
//         let node = queue[index]
//         index += 1
//         if let left = node.left { queue.append(left) }
//         if let right = node.right { queue.append(right) }
//     }
// }

// 22) recursive DFS tree
// func dfs(_ node: TreeNode?) {
//     guard let node else { return }
//     dfs(node.left)
//     dfs(node.right)
// }

// 23) recursive DFS graph/grid
// func dfs(_ r: Int, _ c: Int) {
//     guard r >= 0, r < rows, c >= 0, c < cols else { return }
//     guard grid[r][c] == "1" else { return }
//
//     grid[r][c] = "0"
//     dfs(r + 1, c)
//     dfs(r - 1, c)
//     dfs(r, c + 1)
//     dfs(r, c - 1)
// }

// 24) backtracking template
// func backtrack(_ start: Int) {
//     if /* complete */ {
//         result.append(path)
//         return
//     }
//
//     for i in start..<nums.count {
//         path.append(nums[i])
//         backtrack(i + 1)
//         path.removeLast()
//     }
// }

// 25) interval merge
// let intervals = intervals.sorted { $0[0] < $1[0] }
// var merged: [[Int]] = []
//
// for interval in intervals {
//     if merged.isEmpty || merged[merged.count - 1][1] < interval[0] {
//         merged.append(interval)
//     } else {
//         merged[merged.count - 1][1] = max(merged[merged.count - 1][1], interval[1])
//     }
// }

// ==================================================
// TIER 3 — COMMON SENIOR-LEVEL CLEANUP EXPRESSIONS
// ==================================================

// 26) memoized DFS
// var memo: [Int: Int] = [:]
//
// func dp(_ i: Int) -> Int {
//     if i <= 1 { return i }
//     if let cached = memo[i] { return cached }
//     let ans = dp(i - 1) + dp(i - 2)
//     memo[i] = ans
//     return ans
// }

// 27) bottom-up DP
// if n == 0 { return 0 }
// var dp = Array(repeating: 0, count: n + 1)
// dp[0] = 0
// dp[1] = 1
//
// if n >= 2 { // 2...n crashes when n < 2
//     for i in 2...n {
//         dp[i] = dp[i - 1] + dp[i - 2]
//     }
// }
// return dp[n]

// 28) 2D DP
// var dp = Array(
//     repeating: Array(repeating: 0, count: cols),
//     count: rows
// )

// 29) build adjacency list
// var graph = Array(repeating: [Int](), count: n)
// for edge in edges {
//     let u = edge[0]
//     let v = edge[1]
//     graph[u].append(v)
//     graph[v].append(u)
// }

// 30) indegree for topo sort
// var graph = Array(repeating: [Int](), count: n)
// var indegree = Array(repeating: 0, count: n)
//
// for edge in edges {
//     let u = edge[0]
//     let v = edge[1]
//     graph[u].append(v)
//     indegree[v] += 1
// }

// 31) transpose / matrix traversal
// for r in 0..<grid.count {
//     for c in 0..<grid[0].count {
//     }
// }

// 32) linked list reversal
// var prev: ListNode? = nil
// var curr = head
//
// while curr != nil {
//     let next = curr?.next
//     curr?.next = prev
//     prev = curr
//     curr = next
// }
// return prev

// 33) fast and slow pointer
// var slow = head
// var fast = head
//
// while fast != nil && fast?.next != nil {
//     slow = slow?.next
//     fast = fast?.next?.next
// }

// 34) compare against answer defaults
// var answer = Int.max
// if candidate < answer {
//     answer = candidate
// }

// 35) common boundary check
// func isValid(_ r: Int, _ c: Int) -> Bool {
//     r >= 0 && r < rows && c >= 0 && c < cols
// }

// 36) heap / priority queue (min-heap via sorted array)
// var heap: [Int] = []
//
// func heapInsert(_ val: Int) {
//     heap.append(val)
//     heap.sort()
// }
//
// func heapExtractMin() -> Int? {
//     heap.isEmpty ? nil : heap.removeFirst()
// }
//
// // top K largest: keep a min-heap of size K
// var minHeap: [Int] = []
// for x in nums {
//     minHeap.append(x)
//     minHeap.sort()
//     if minHeap.count > k {
//         minHeap.removeFirst()
//     }
// }
// // minHeap[0] is the Kth largest

// 37) union-find
// var parent: [Int] = Array(0..<n)
// var rank: [Int] = Array(repeating: 0, count: n)
//
// func find(_ x: Int) -> Int {
//     if parent[x] != x {
//         parent[x] = find(parent[x])
//     }
//     return parent[x]
// }
//
// func union(_ x: Int, _ y: Int) {
//     let px = find(x)
//     let py = find(y)
//     if px == py { return }
//     if rank[px] < rank[py] {
//         parent[px] = py
//     } else if rank[px] > rank[py] {
//         parent[py] = px
//     } else {
//         parent[py] = px
//         rank[px] += 1
//     }
// }

// ==================================================
// MICRO-KATA RULES
// ==================================================
//
// Round 1:
// Type lines 1-15 only.
//
// Round 2:
// Type 1-25.
//
// Round 3:
// Type 1-37.
//
// Round 4:
// Delete comments and type from memory.
//
// Round 5:
// For each pattern, name 2 problems it fits.
//
// Round 6:
// Given a problem statement, identify which 2-3 patterns to combine
// (e.g. "sliding window + frequency map" for longest substring without repeating).

// ==================================================
// MAPPING: WHAT TO THINK WHEN YOU SEE THE PROMPT
// ==================================================
//
// array/string + pair + sorted -> two pointers
// array/string + longest/shortest contiguous -> sliding window
// lookup/count/frequency -> dictionary or set
// sorted + find boundary/value -> binary search
// tree -> DFS/BFS
// grid shortest path -> BFS
// grid connected components -> DFS/BFS
// overlapping ranges -> intervals
// choices/combinations/permutations -> backtracking
// optimal substructure/min steps/count ways -> DP
// top K / repeated best extraction -> heap
// dependency order -> topological sort
// next greater / monotonic behavior -> stack
// cycle / middle of linked list -> fast and slow pointers
// connected components / redundant edges -> union-find
