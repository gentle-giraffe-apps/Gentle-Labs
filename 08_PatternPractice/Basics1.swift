// PRACTICE DRILLS
// Copy and paste into your favorite online Swift editor.
// Retype all the info to gain muscle memory.

// Arrays
//
//    var s = "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
//    var nums = s.split(separator: " ").compactMap { Int($0) }
//    nums.shuffle()
//    var freq = [Int: Int]()
//    
//    nums.sort()
//    var (maximum, minimum) = (nums[0], nums[0])
//    
//    for n in nums.reversed() {
//        freq[n, default: 0] += 1
//        maximum = max(maximum, n)
//        minimum = min(minimum, n)
//    }
//    
//    print("freq:", freq, "min:", minimum, "max:", maximum)
//    
//    let popLast = nums.popLast()
//    let evens = nums.filter { $0 % 2 == 0 }
//    let doubled = nums.map { $0 * 2 }
//    let sum = nums.reduce(0, +)
//    let (first, last, count, aMin, aMax) = (nums.first, nums.last, nums.count, nums.min(), nums.max())
//

// Strings
//
//    let text = "Hello world. This program is written in Swift. Version 3.14.159"
//    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
//    let (lowercased, uppercased) = (trimmed.lowercased(), trimmed.uppercased())
//    let words = lowercased.split(separator: " ")
//    let hasSwift = lowercased.contains("swift")
//    let joined = words.joined(separator: "/")
//    let chars = Array(trimmed)
//    let letterChars = chars.filter { $0.isLetter }
//    let numberChars = chars.filter { $0.isNumber }

// Data Structures
//
//    class TreeNode {
//      var data: Int
//      var left, right: TreeNode?
//      init(_ data: Int = 0, _ left: TreeNode? = nil, _ right: TreeNode? = nil) {
//        (self.data, self.left, self.right) = (data, left, right)
//      }
//    }
//
//    func preOrder(_ node: TreeNode?, _ visit: (Int) -> ()) {
//      guard let node else { return }
//      visit(node.data)
//      preOrder(node.left, visit); preOrder(node.right, visit)
//    }
//
//    func height(_ node: TreeNode?) -> Int {
//      guard let node else { return 0 }
//      return 1 + max(height(node.left), height(node.right))
//    }
//
//    func invert(_ node: TreeNode?) -> TreeNode? {
//      guard let node else { return nil }
//      node.left = invert(node.right)
//      node.right = invert(node.left)
//      return node
//    }

// Algorithms
//
//    func binarySearch(nums: [Int], target: Int) -> Int? {
//        var (low, hi) = (0, nums.count - 1)
//        while low <= hi {
//            let mid = low + (hi - low) / 2
//            if target == nums[mid] {
//                 return mid
//            } else if target > nums[mid] {
//                 low = mid + 1
//            } else {
//                 hi = mid - 1
//            }
//    }
//    print("index for 3: \(binarySearch(nums: nums, target: 3))")
