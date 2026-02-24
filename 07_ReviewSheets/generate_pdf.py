#!/usr/bin/env python3
"""Generate a QuickStudy-style PDF cheat sheet for Swift / iOS / DSA."""

from fpdf import FPDF
import os

# ── Colors ────────────────────────────────────────────────
HEADER_BG   = (30, 60, 110)    # dark blue
SECTION_BG  = (55, 90, 145)    # medium blue
SUBSECT_BG  = (200, 215, 235)  # light blue
CODE_BG     = (245, 245, 245)  # light gray
WHITE       = (255, 255, 255)
BLACK       = (30, 30, 30)
DARK_GRAY   = (60, 60, 60)

class CheatSheet(FPDF):
    def __init__(self):
        super().__init__(orientation="L", unit="mm", format="letter")
        self.set_auto_page_break(auto=False)
        self.col_count = 3
        self.margin = 6
        self.col_gap = 4
        self.usable_w = self.w - 2 * self.margin
        self.col_w = (self.usable_w - (self.col_count - 1) * self.col_gap) / self.col_count
        self.col_idx = 0
        self.col_x = self.margin
        self.col_top = 18  # below page header
        self.col_y = self.col_top
        self.current_page_title = ""
        self._last_subsect = None  # orphan prevention tracking

    def page_header(self, title):
        self.current_page_title = title
        self.set_fill_color(*HEADER_BG)
        self.set_text_color(*WHITE)
        self.set_font("Helvetica", "B", 14)
        self.rect(0, 0, self.w, 14, "F")
        self.set_xy(self.margin, 2)
        self.cell(self.usable_w, 10, title, align="C")
        self.col_y = self.col_top

    def _col_left(self):
        return self.margin + self.col_idx * (self.col_w + self.col_gap)

    def _check_space(self, needed):
        if self.col_y + needed > self.h - self.margin:
            self.col_idx += 1
            self.col_y = self.col_top
            if self.col_idx >= self.col_count:
                self.add_page()
                base = self.current_page_title.replace(" (cont.)", "")
                self.page_header(base + " (cont.)")
                self.col_idx = 0
                self.col_y = self.col_top

    def _check_space_keep_subsect(self, needed):
        """Like _check_space, but if a subsection header was just placed on
        this column and the content would overflow, erase the orphaned header
        and re-draw it on the new column/page so header + content stay together."""
        sub = self._last_subsect
        if sub is not None:
            title, sub_y, sub_page, sub_col = sub
            same_loc = (sub_page == self.page and sub_col == self.col_idx)
            would_overflow = (self.col_y + needed > self.h - self.margin)
            if same_loc and would_overflow:
                # White-out the orphaned header
                self.set_fill_color(*WHITE)
                self.rect(self._col_left(), sub_y, self.col_w,
                          self.col_y - sub_y, "F")
                self.col_y = sub_y
                # Break with room for header + content
                self._check_space(5.5 + needed)
                # Re-draw subsection header in new location
                x = self._col_left()
                self.set_fill_color(*SUBSECT_BG)
                self.set_text_color(*BLACK)
                self.set_font("Helvetica", "B", 6.5)
                self.set_xy(x, self.col_y)
                self.cell(self.col_w, 4.5, f"  {title}", fill=True)
                self.col_y += 5.5
                self._last_subsect = None
                return
            self._last_subsect = None
        self._check_space(needed)

    def new_page(self, title):
        """Force a new page with the given header title."""
        self.add_page()
        self.page_header(title)
        self.col_idx = 0
        self.col_y = self.col_top
        self._last_subsect = None

    def section(self, title):
        self._last_subsect = None
        self._check_space(7)
        x = self._col_left()
        self.set_fill_color(*SECTION_BG)
        self.set_text_color(*WHITE)
        self.set_font("Helvetica", "B", 8)
        self.set_xy(x, self.col_y)
        self.cell(self.col_w, 5.5, f"  {title}", fill=True)
        self.col_y += 6.5

    def subsection(self, title):
        # Reserve enough for header + at least 2 code lines to avoid orphans
        self._check_space(6 + 2 * 3.4 + 2)
        x = self._col_left()
        self.set_fill_color(*SUBSECT_BG)
        self.set_text_color(*BLACK)
        self.set_font("Helvetica", "B", 6.5)
        self.set_xy(x, self.col_y)
        self.cell(self.col_w, 4.5, f"  {title}", fill=True)
        # Track for orphan prevention (title, y_start, page, col_idx)
        self._last_subsect = (title, self.col_y, self.page, self.col_idx)
        self.col_y += 5.5

    def code_block(self, text):
        lines = text.strip().split("\n")
        needed = len(lines) * 3.4 + 2
        self._check_space_keep_subsect(needed)
        self.set_font("Courier", "", 5.5)
        self.set_text_color(*DARK_GRAY)
        # Dynamic max chars (Courier is monospace)
        available_w = self.col_w - 2
        max_chars = int(available_w / self.get_string_width("M"))
        x = self._col_left()
        y_start = self.col_y
        self.set_fill_color(*CODE_BG)
        self.rect(x, y_start, self.col_w, needed, "F")
        cy = y_start + 1
        for line in lines:
            self.set_xy(x + 1, cy)
            self.cell(available_w, 3.2, line[:max_chars])
            cy += 3.4
        self.col_y = y_start + needed + 0.5

    def body_text(self, text):
        lines = text.strip().split("\n")
        needed = len(lines) * 3.2 + 1
        self._check_space_keep_subsect(needed)
        self.set_font("Helvetica", "", 6)
        self.set_text_color(*DARK_GRAY)
        x = self._col_left()
        available_w = self.col_w - 3
        for line in lines:
            self.set_xy(x + 1.5, self.col_y)
            truncated = line
            while len(truncated) > 0 and self.get_string_width(truncated) > available_w:
                truncated = truncated[:-1]
            self.cell(available_w, 3, truncated)
            self.col_y += 3.2
        self.col_y += 1

    def compact_list(self, label, items):
        """Label in bold, items comma-separated, wrapping within column."""
        x = self._col_left()
        self.set_font("Helvetica", "B", 6)
        self.set_text_color(*BLACK)
        label_w = self.get_string_width(label + " ") + 1

        self.set_font("Helvetica", "", 5.8)
        self.set_text_color(*DARK_GRAY)
        item_str = ", ".join(items)
        full = label + " " + item_str

        # estimate lines needed
        available_w = self.col_w - 3
        est_lines = max(1, int(self.get_string_width(full) / available_w) + 1)
        needed = est_lines * 3.2 + 1
        self._check_space(needed)
        x = self._col_left()

        self.set_xy(x + 1.5, self.col_y)
        self.set_font("Helvetica", "B", 6)
        self.set_text_color(*BLACK)
        self.cell(label_w, 3, label + " ")

        self.set_font("Courier", "", 5.5)
        self.set_text_color(*DARK_GRAY)
        self.set_xy(x + 1.5 + label_w, self.col_y)
        self.multi_cell(available_w - label_w, 3.2, item_str)
        self.col_y = self.get_y() + 0.8

    def spacer(self, h=2):
        self.col_y += h


def build():
    pdf = CheatSheet()

    # ══════════════════════════════════════════════════════════
    #  PAGE 1 -- Swift Fundamentals & DSA
    # ══════════════════════════════════════════════════════════
    pdf.add_page()
    pdf.page_header("Swift Fundamentals & DSA")

    # ── STRING ──
    pdf.section("String")
    pdf.compact_list("Properties:", ["count", "isEmpty", "startIndex", "endIndex"])
    pdf.compact_list("Case:", ["lowercased()", "uppercased()"])
    pdf.compact_list("Search:", ["contains(_:)", "hasPrefix(_:)", "hasSuffix(_:)", "starts(with:)"])
    pdf.compact_list("Transform:", [
        "reversed()", "split(separator:)", "components(separatedBy:)",
        "trimmingCharacters(in:)", "replacingOccurrences(of:with:)"
    ])
    pdf.compact_list("Init:", ["String(42)", "String(3.14)", 'String(repeating:count:)'])
    pdf.compact_list("Character:", ["isLetter", "isNumber", "isWhitespace", "asciiValue"])
    pdf.code_block(
        's[s.index(s.startIndex, offsetBy: 4)]   // index access'
    )

    # ── ARRAY ──
    pdf.section("Array")
    pdf.compact_list("Access:", ["first", "last", "count", "isEmpty", "min()", "max()"])
    pdf.compact_list("Mutate:", [
        "append(_:)", "insert(_:at:)", "remove(at:)", "removeFirst()",
        "removeLast()", "removeAll()", "swapAt(_:_:)"
    ])
    pdf.compact_list("Order:", ["sort()", "sorted()", "sorted(by: >)", "reverse()", "reversed()", "shuffle()"])
    pdf.compact_list("Search:", ["contains(_:)", "firstIndex(of:)", "first(where:)", "contains(where:)"])
    pdf.compact_list("Slice:", ["prefix(_:)", "suffix(_:)", "a[0..<3]"])
    pdf.compact_list("Init:", [
        "Array(repeating:count:)", "Array(0..<10)",
        "Array(stride(from:to:by:))"
    ])
    # ── DICTIONARY ──
    pdf.section("Dictionary")
    pdf.compact_list("Access:", ['d["k"]', 'd["k", default: 0]', "d.keys", "d.values", "d.count", "d.isEmpty"])
    pdf.compact_list("Mutate:", ['d["k"] = v', "removeValue(forKey:)", "merge(_:uniquingKeysWith:)", "mapValues(_:)"])
    pdf.compact_list("Query:", ["contains(where:)"])
    pdf.code_block(
        '// Counting:  d[key, default: 0] += 1\n'
        '// Freq map:  arr.reduce(into: [:]) { $0[$1, default: 0] += 1 }'
    )
    pdf.subsection("Sparse Grid (avoids 2D array + bounds checking)")
    pdf.code_block(
        'var grid = [[Int]: Int]()        // [Int] is Hashable\n'
        'grid[[23, 77]] = 1               // no allocation, no bounds\n'
        'grid[[-1, -1], default: 0]       // missing keys -> default\n'
        '// Works for any dim: grid[[x, y, z]] for 3D'
    )

    # ── SET ──
    pdf.section("Set")
    pdf.compact_list("Mutate:", ["insert(_:)", "remove(_:)", "contains(_:)", "count", "isEmpty"])
    pdf.compact_list("Algebra:", [
        "union(_:)", "intersection(_:)", "subtracting(_:)",
        "symmetricDifference(_:)", "isSubset(of:)", "isSuperset(of:)"
    ])

    # ── TUPLE & COMPARABLE ──
    pdf.section("Tuple & Comparable")
    pdf.code_block(
        'let pair = (x: 1, y: 2)         // pair.x or pair.0\n'
        '// Comparable element-wise (up to 6 elements):\n'
        '(1, "b") < (2, "a")             // true -- compares 1st first'
    )

    # ── HIGHER-ORDER FUNCTIONS ──
    pdf.section("Higher-Order Functions")
    pdf.code_block(
        '.map { $0 * 2 }                     .compactMap { Int($0) }\n'
        '.flatMap { $0 }                      .filter { $0 % 2 == 0 }\n'
        '.reduce(0, +)                        .reduce(into: [:]) { ... }\n'
        '.forEach { print($0) }               .sorted(by: >)\n'
        '.enumerated()                        .allSatisfy { $0 > 0 }\n'
        '.first(where: { $0 > 1 })            .contains(where: { $0 > 2 })\n'
        '.prefix(while: { $0 < 3 })           .drop(while: { $0 < 3 })\n'
        'zip(a, b)                             for (i, v) in arr.enumerated() {}'
    )

    # ── NEETCODE DSA CATEGORIES ──
    pdf.section("NeetCode DSA Categories")
    categories = [
        ("1. Arrays & Hashing", "freq maps, two sum, group anagrams, top-K frequent"),
        ("2. Two Pointers", "valid palindrome, 3sum, container with most water"),
        ("3. Sliding Window", "best time buy/sell, longest substr w/o repeating"),
        ("4. Stack", "valid parens, min stack, eval reverse polish, daily temps"),
        ("5. Binary Search", "search rotated arr, find min rotated, koko bananas"),
        ("6. Linked List", "reverse, merge two sorted, detect cycle, LRU cache"),
        ("7. Trees", "invert, max depth, level order, validate BST, serialize"),
        ("8. Tries", "implement trie, word search II"),
        ("9. Heap / Priority Queue", "kth largest, merge k sorted, find median stream"),
        ("10. Backtracking", "subsets, permutations, combination sum, n-queens"),
        ("11. Graphs", "num islands, clone graph, course schedule, word ladder"),
        ("12. Adv. Graphs", "Dijkstra, Prim/Kruskal MST, network delay time"),
        ("13. 1-D DP", "climbing stairs, house robber, LIS, coin change"),
        ("14. 2-D DP", "unique paths, LCS, edit distance"),
        ("15. Greedy", "max subarray (Kadane), jump game, gas station"),
        ("16. Intervals", "merge intervals, insert interval, meeting rooms"),
        ("17. Math & Geometry", "rotate image, spiral matrix, set matrix zeroes"),
        ("18. Bit Manipulation", "single number, counting bits, reverse bits"),
    ]
    for cat, problems in categories:
        pdf.compact_list(cat, [problems])

    # ── COMMON DSA PATTERNS ──
    pdf.section("DSA Patterns - Swift Idioms")

    pdf.subsection("Hash Map Counting")
    pdf.code_block('for c in str { freq[c, default: 0] += 1 }')

    pdf.subsection("Two Pointers")
    pdf.code_block('var lo = 0, hi = arr.count - 1\nwhile lo < hi { lo += 1; hi -= 1 }')

    pdf.subsection("Sliding Window")
    pdf.code_block(
        'var left = 0\n'
        'for right in 0..<arr.count {\n'
        '    while /* invalid */ { left += 1 }\n'
        '}'
    )

    pdf.subsection("BFS (head-index: O(1) dequeue)")
    pdf.code_block(
        'var queue = [start]; var head = 0\n'
        'var visited = Set([start])\n'
        'while head < queue.count {\n'
        '    let node = queue[head]; head += 1\n'
        '    for nb in graph[node, default: []]\n'
        '        where !visited.contains(nb) {\n'
        '        visited.insert(nb); queue.append(nb)\n'
        '    }\n'
        '}\n'
        '// removeFirst() is O(n) -- head index is O(1)'
    )

    pdf.subsection("DFS (Recursive)")
    pdf.code_block(
        'func dfs(_ node: Int) {\n'
        '    visited.insert(node)\n'
        '    for nb in graph[node, default: []]\n'
        '        where !visited.contains(nb) {\n'
        '        dfs(nb)\n'
        '    }\n'
        '}'
    )

    pdf.subsection("Binary Search")
    pdf.code_block(
        'var lo = 0, hi = arr.count - 1\n'
        'while lo <= hi {\n'
        '    let mid = lo + (hi - lo) / 2\n'
        '    if arr[mid] == target { return mid }\n'
        '    arr[mid] < target ? (lo = mid + 1) : (hi = mid - 1)\n'
        '}'
    )

    pdf.subsection("Heap / Top-K")
    pdf.code_block(
        '// No stdlib heap -- sort-based top-K:\n'
        'arr.sorted(by: >).prefix(k)\n'
        '// O(n log k): import Collections -> Heap<Int>'
    )

    pdf.subsection("Stack / Monotonic Stack")
    pdf.code_block(
        '// Stack: append (push), removeLast (pop), last (peek)\n'
        '// Monotonic (next greater element):\n'
        'for i in 0..<arr.count {\n'
        '    while let top = stk.last, arr[top] < arr[i] {\n'
        '        result[stk.removeLast()] = arr[i]\n'
        '    }; stk.append(i)\n'
        '}'
    )

    pdf.subsection("Deque (Sliding Window Max)")
    pdf.code_block(
        'var deque = [Int]()  // indices, front = max\n'
        'for i in 0..<arr.count {\n'
        '    while let b = deque.last, arr[b] <= arr[i] {\n'
        '        deque.removeLast() }\n'
        '    deque.append(i)\n'
        '    if deque.first! <= i - k { deque.removeFirst() }\n'
        '    if i >= k - 1 { result.append(arr[deque.first!]) }\n'
        '}'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 2 -- iOS APIs & Networking
    # ══════════════════════════════════════════════════════════
    pdf.new_page("iOS APIs & Networking")

    # ── USERDEFAULTS (slim) ──
    pdf.section("UserDefaults")
    pdf.code_block(
        'let ud = UserDefaults.standard\n'
        'ud.set(value, forKey: "k")     // Int, String, Bool, Array, Data\n'
        'ud.integer(forKey:)            // .string, .bool, .array, .double\n'
        'ud.removeObject(forKey: "k")\n'
        '// Codable structs won\'t auto-decode -- use Data + JSONEncoder/Decoder'
    )

    # ── FILEMANAGER ──
    pdf.section("FileManager")
    pdf.code_block(
        'let fm = FileManager.default\n'
        'let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]\n'
        'let url = docs.appending(path: "data.json")  // iOS 16+\n'
        'try data.write(to: url)              // write\n'
        'let d = try Data(contentsOf: url)    // read\n'
        'fm.fileExists(atPath: url.path)      // check\n'
        'try fm.removeItem(at: url)           // delete\n'
        'try fm.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)'
    )

    # ── BUNDLE RESOURCES ──
    pdf.section("Bundle Resources")
    pdf.code_block(
        '// Load bundled JSON file\n'
        'guard let url = Bundle.main.url(\n'
        '    forResource: "data", withExtension: "json"\n'
        ') else { fatalError("Missing resource") }\n'
        'let data = try Data(contentsOf: url)\n'
        'let items = try JSONDecoder().decode(\n'
        '    [Item].self, from: data)\n'
        '\n'
        '// Load bundled text file\n'
        'let text = try String(\n'
        '    contentsOf: Bundle.main.url(\n'
        '        forResource: "info", withExtension: "txt"\n'
        '    )!, encoding: .utf8)'
    )
    pdf.body_text(
        'Files must be in target\'s "Copy Bundle Resources"\n'
        'build phase. Bundle is read-only at runtime.'
    )

    # ── URLSESSION + JSONDECODER ──
    pdf.section("URLSession GET + JSONDecoder")
    pdf.code_block(
        'let url = URL(string: "https://api.example.com/items")!\n'
        'let (data, resp) = try await URLSession.shared.data(from: url)\n'
        'guard let http = resp as? HTTPURLResponse,\n'
        '      http.statusCode == 200\n'
        'else { throw URLError(.badServerResponse) }\n'
        'let items = try JSONDecoder().decode([Item].self, from: data)'
    )
    pdf.subsection("With URLRequest & Decoder Options")
    pdf.code_block(
        'var req = URLRequest(url: url)\n'
        'req.setValue("application/json", forHTTPHeaderField: "Accept")\n'
        'let (data, _) = try await URLSession.shared.data(for: req)\n'
        '\n'
        'let dec = JSONDecoder()\n'
        'dec.keyDecodingStrategy = .convertFromSnakeCase\n'
        'dec.dateDecodingStrategy = .iso8601'
    )

    # ── STRUCTURED CONCURRENCY ──
    pdf.section("Structured Concurrency")
    pdf.subsection("async let (parallel calls)")
    pdf.code_block(
        'async let user = fetchUser(id: 1)\n'
        'async let posts = fetchPosts(id: 1)\n'
        'let (u, p) = try await (user, posts)  // both run concurrently'
    )
    pdf.subsection("TaskGroup (dynamic parallelism)")
    pdf.code_block(
        'let results = await withTaskGroup(of: String.self) { group in\n'
        '    for url in urls {\n'
        '        group.addTask(name: "fetch-\\(url)") {\n'
        '            await fetch(url)\n'
        '        }\n'
        '    }\n'
        '    var collected = [String]()\n'
        '    for await result in group { collected.append(result) }\n'
        '    return collected\n'
        '}\n'
        '// withThrowingTaskGroup for tasks that can throw'
    )

    # ── TASK (UNSTRUCTURED) ──
    pdf.section("Task (Unstructured)")
    pdf.code_block(
        '// Fire-and-forget (inherits actor context)\n'
        'Task(name: "refreshData") { await refreshData() }\n'
        '\n'
        '// Store handle -- access value or cancel later\n'
        'let task = Task<String, Error>(name: "fetchName") {\n'
        '    try await fetchUserName()\n'
        '}\n'
        'let name = try await task.value   // blocks until done\n'
        'task.cancel()                     // cooperative cancel\n'
        '\n'
        '// Detached -- does NOT inherit actor context\n'
        'Task.detached(name: "bg-export", priority: .background) {\n'
        '    await exportLargeFile()\n'
        '}\n'
        '\n'
        '// Read current task name (useful in logging)\n'
        'if let n = Task.name { print("Running: \\(n)") }\n'
        '\n'
        '// Priorities: .userInitiated .medium .utility .background'
    )

    # ── SWIFTUI .task ──
    pdf.section("SwiftUI .task")
    pdf.code_block(
        '// Runs on appear, auto-cancelled on disappear\n'
        '.task { await viewModel.loadData() }\n'
        '\n'
        '// Re-runs when id changes (old task cancelled)\n'
        '.task(id: selectedTab) {\n'
        '    await viewModel.load(tab: selectedTab)\n'
        '}'
    )

    # ── SWIFTUI PROPERTY WRAPPERS ──
    pdf.section("SwiftUI Property Wrappers")
    pdf.subsection("Value Types (view-owned state)")
    pdf.code_block(
        '@State private var count = 0   // View OWNS. Survives re-renders.\n'
        '@Binding var isOn: Bool        // Two-way ref to parent @State.\n'
        '    // Created with $: Toggle(isOn: $vm.isOn)'
    )
    pdf.subsection("Reference Types (ObservableObject)")
    pdf.code_block(
        '@StateObject private var vm = VM()  // View OWNS. Created once.\n'
        '@ObservedObject var vm: VM          // Passed in. NOT owned.\n'
        '@EnvironmentObject var vm: VM       // via .environmentObject()'
    )
    pdf.subsection("Inside ObservableObject")
    pdf.code_block(
        'class VM: ObservableObject {\n'
        '    @Published var items: [Item] = []  // triggers view re-render\n'
        '}'
    )
    pdf.subsection("Environment & Persistence")
    pdf.code_block(
        '@Environment(\\.colorScheme) var scheme  // system values\n'
        '@Environment(\\.dismiss) var dismiss\n'
        '@AppStorage("username") var name = ""   // UserDefaults-backed\n'
        '@SceneStorage("draft") var draft = ""   // per-scene state\n'
        '@FocusState private var focused: Bool   // keyboard focus'
    )
    pdf.subsection("iOS 17+ @Observable (replaces ObservableObject)")
    pdf.code_block(
        '@Observable class VM {               // no @Published needed\n'
        '    var items: [Item] = []           // all props tracked auto\n'
        '}\n'
        '@Bindable var vm: VM                 // creates bindings to props'
    )
    pdf.body_text(
        '@State/@StateObject: view OWNS (creation)\n'
        '@Binding/@ObservedObject: view BORROWS (from parent)\n'
        '@EnvironmentObject: view FINDS (injected up tree)\n'
        '@Observable + @Bindable: iOS 17+ (simpler, efficient)'
    )

    # ── SWIFTUI COMPONENTS ──
    pdf.section("SwiftUI Components")
    pdf.subsection("Text & Labels")
    pdf.code_block(
        'Text("Hello")                        // static/dynamic text\n'
        'Label("Settings", systemImage: "gear")// icon + text\n'
        'Image(systemName: "star.fill")       // SF Symbol\n'
        'Image("photo")                      // asset catalog\n'
        '    .resizable()                    // required to resize\n'
        '    .aspectRatio(contentMode: .fill) // .fit or .fill\n'
        '    .frame(width: 200, height: 150)\n'
        '    .clipShape(RoundedRectangle(cornerRadius: 12))\n'
        'AsyncImage(url: url)                 // remote image'
    )
    pdf.subsection("Buttons & Input")
    pdf.code_block(
        'Button("Tap") { action() }          // tappable\n'
        'Toggle("Wi-Fi", isOn: $isOn)        // on/off switch\n'
        'Slider(value: $v, in: 0...100)      // range\n'
        'Stepper("Qty: \\(q)", value: $q)     // +/- buttons\n'
        'Picker("Sort", selection: $s) { }   // dropdown/segmented\n'
        'DatePicker("Date", selection: $d)   // date/time\n'
        'ColorPicker("Color", selection: $c) // color'
    )
    pdf.subsection("Text Input")
    pdf.code_block(
        'TextField("Name", text: $text)      // single-line\n'
        'SecureField("Pass", text: $pw)      // masked\n'
        'TextEditor(text: $body)             // multi-line'
    )
    pdf.subsection("Layout")
    pdf.code_block(
        'VStack { }  HStack { }  ZStack { } // stacks\n'
        'LazyVStack { }  LazyHStack { }     // lazy (scroll perf)\n'
        'Grid { GridRow { } }               // 2D grid (iOS 16+)\n'
        'Spacer()  Divider()                // fill / separator\n'
        'GeometryReader { geo in }          // parent size/pos'
    )
    pdf.subsection("Lists & Scroll")
    pdf.code_block(
        'List(items) { item in Row(item) }  // scrollable rows\n'
        'ForEach(items) { item in ... }     // loop in containers\n'
        'ScrollView(.vertical) { }          // free-form scroll\n'
        'LazyVGrid(columns: cols) { }       // vertical grid\n'
        'LazyHGrid(rows: rows) { }          // horizontal grid'
    )
    pdf.subsection("List Skeleton (UITableView analog)")
    pdf.code_block(
        'List(selection: $selected) {\n'
        '    Section("Favorites") {          // header\n'
        '        ForEach(filtered) { item in\n'
        '            Row(item: item)\n'
        '                .swipeActions(edge: .trailing) {\n'
        '                    Button("Delete",\n'
        '                        role: .destructive) { del(item) }\n'
        '                }\n'
        '                .swipeActions(edge: .leading) {\n'
        '                    Button("Pin") { pin(item) }\n'
        '                }\n'
        '        }\n'
        '        .onDelete { offsets in remove(offsets) }\n'
        '        .onMove { from, to in move(from, to) }\n'
        '    } footer: {\n'
        '        Text("\\(filtered.count) items")\n'
        '    }\n'
        '}\n'
        '.searchable(text: $query)          // search bar\n'
        '.refreshable { await reload() }    // pull-to-refresh\n'
        '.listStyle(.insetGrouped)          // .plain .grouped\n'
        '.environment(\\.editMode, $mode)    // enable edit mode'
    )
    pdf.body_text(
        'List = UICollectionView under the hood (iOS 16+).\n'
        'Cell reuse, lazy rendering, diffable updates, prefetch.\n'
        'ForEach in List is lazy; in ScrollView/VStack is eager.'
    )
    pdf.subsection("Navigation")
    pdf.code_block(
        'NavigationStack { }                // push/pop (iOS 16+)\n'
        'NavigationLink("Detail") { View() }// push trigger\n'
        'NavigationSplitView { } detail: { }// sidebar+detail\n'
        'TabView { }.tabItem { Label(...) } // tab bar'
    )
    pdf.subsection("NavigationDestination (data-driven)")
    pdf.code_block(
        'NavigationLink(value: item) { Text(item.name) }\n'
        '.navigationDestination(for: Item.self) { item in\n'
        '    DetailView(item: item)\n'
        '}'
    )
    pdf.subsection("Coordinator Pattern (iOS 17+)")
    pdf.code_block(
        'enum Route: Hashable {\n'
        '    case detail(Item)\n'
        '    case settings\n'
        '}\n'
        '\n'
        '@Observable class Coordinator {\n'
        '    var path = NavigationPath()\n'
        '    func push(_ r: Route) { path.append(r) }\n'
        '    func pop() { path.removeLast() }\n'
        '    func popToRoot() { path.removeLast(path.count) }\n'
        '\n'
        '    @ViewBuilder\n'
        '    func view(for route: Route) -> some View {\n'
        '        switch route {\n'
        '        case .detail(let item): DetailView(item: item)\n'
        '        case .settings:         SettingsView()\n'
        '        }\n'
        '    }\n'
        '}'
    )
    pdf.subsection("NavigationStack + Path")
    pdf.code_block(
        '@State private var coordinator = Coordinator()\n'
        '\n'
        'NavigationStack(path: $coordinator.path) {\n'
        '    HomeView()\n'
        '        .navigationDestination(for: Route.self) {\n'
        '            coordinator.view(for: $0)\n'
        '        }\n'
        '}'
    )
    pdf.subsection("Containers & Presentation")
    pdf.code_block(
        'Form { }  Section("Hdr") { }       // settings list\n'
        'GroupBox("Title") { }              // bordered box\n'
        'DisclosureGroup("More") { }        // expandable\n'
        '.sheet(isPresented: $show) { }     // modal sheet\n'
        '.alert("Title", isPresented: $s)   // alert dialog\n'
        '.fullScreenCover(...)              // full-screen modal\n'
        '.popover(isPresented: $show) { }  // popover (iPad)\n'
        '.confirmationDialog(...)           // action sheet'
    )
    pdf.subsection("Progress & Status")
    pdf.code_block(
        'ProgressView()                     // spinner\n'
        'ProgressView(value: 0.5)           // progress bar\n'
        'Gauge(value: 0.7) { Text("CPU") } // gauge (iOS 16+)'
    )
    pdf.subsection("Maps & Web")
    pdf.code_block(
        'Map(position: $pos) { }             // MapKit (iOS 17+)\n'
        '// WKWebView: use UIViewRepresentable'
    )

    # ── CODABLE STRUCT + CODINGKEYS ──
    pdf.section("Codable Struct + CodingKeys")
    pdf.code_block(
        'struct User: Codable {\n'
        '    let id: Int\n'
        '    let firstName: String\n'
        '    let avatarURL: String\n'
        '    let createdAt: Date\n'
        '\n'
        '    enum CodingKeys: String, CodingKey {\n'
        '        case id\n'
        '        case firstName = "first_name"\n'
        '        case avatarURL = "avatar_url"\n'
        '        case createdAt = "created_at"\n'
        '    }\n'
        '}'
    )
    pdf.body_text(
        'CodingKeys map JSON snake_case to Swift camelCase.\n'
        'Alt: decoder.keyDecodingStrategy = .convertFromSnakeCase'
    )

    # ── CUSTOM DECODING ──
    pdf.section("Custom Decoding")
    pdf.code_block(
        'struct Post: Codable {\n'
        '    let id: Int\n'
        '    let title: String\n'
        '    let tags: [String]\n'
        '\n'
        '    enum CodingKeys: String, CodingKey {\n'
        '        case id, title\n'
        '        case tags = "post_tags"   // JSON key differs\n'
        '    }\n'
        '\n'
        '    init(from decoder: Decoder) throws {\n'
        '        let c = try decoder.container(keyedBy: CodingKeys.self)\n'
        '        id    = try c.decode(Int.self, forKey: .id)\n'
        '        title = try c.decode(String.self, forKey: .title)\n'
        '        tags  = try c.decodeIfPresent([String].self,\n'
        '                    forKey: .tags) ?? []\n'
        '    }\n'
        '}'
    )
    pdf.body_text(
        'decodeIfPresent: nil if key missing/null (vs throwing)\n'
        'nestedContainer: for nested JSON objects\n'
        'singleValueContainer: for wrapper types\n'
        'unkeyedContainer: for arrays element-by-element'
    )

    # ── RESILIENT ENUM ──
    pdf.section("Resilient Enum (DTO Best Practice)")
    pdf.body_text(
        'Problem: API adds new enum values -> app crashes on decode\n'
        'Solution: catch-all case preserves the raw value'
    )
    pdf.code_block(
        'enum Status: Decodable, Equatable {\n'
        '    case active, inactive, archived\n'
        '    case unknown(String)    // catch-all\n'
        '\n'
        '    init(from decoder: Decoder) throws {\n'
        '        let val = try decoder.singleValueContainer()\n'
        '                      .decode(String.self)\n'
        '        switch val {\n'
        '        case "active":   self = .active\n'
        '        case "inactive": self = .inactive\n'
        '        case "archived": self = .archived\n'
        '        default:         self = .unknown(val)\n'
        '        }\n'
        '    }\n'
        '}'
    )
    pdf.body_text(
        '{"status":"pending"} -> .unknown("pending")'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE -- Platform Patterns
    # ══════════════════════════════════════════════════════════
    pdf.new_page("Platform Patterns")

    # ── IN-FLIGHT COALESCING CACHE ──
    pdf.section("In-Flight Coalescing Cache")
    pdf.body_text(
        'Dedup concurrent requests for the same key.\n'
        'Common for: image loading, API calls, token refresh.'
    )
    pdf.code_block(
        'actor RequestCoalescer<Key: Hashable, Value: Sendable> {\n'
        '    private var inFlight: [Key: Task<Value, Error>] = [:]\n'
        '\n'
        '    func fetch(\n'
        '        key: Key,\n'
        '        work: @Sendable () async throws -> Value\n'
        '    ) async throws -> Value {\n'
        '        if let existing = inFlight[key] {\n'
        '            return try await existing.value // reuse\n'
        '        }\n'
        '        let task = Task { try await work() }\n'
        '        inFlight[key] = task\n'
        '        defer { inFlight[key] = nil }\n'
        '        return try await task.value\n'
        '    }\n'
        '}'
    )
    pdf.code_block(
        '// Usage -- Data is Sendable (UIImage is NOT)\n'
        'let loader = RequestCoalescer<URL, Data>()\n'
        'let data = try await loader.fetch(key: url) {\n'
        '    let (d, _) = try await URLSession\n'
        '        .shared.data(from: url)\n'
        '    return d\n'
        '}\n'
        'let image = UIImage(data: data)  // decode on caller'
    )

    # ── ACTOR REENTRANCY ──
    pdf.section("Actor Reentrancy")
    pdf.body_text(
        'Each await is a suspension point -- other callers\n'
        'can interleave. Never split a critical section\n'
        '(read-modify-write) across an await.'
    )
    pdf.code_block(
        '// BUG: read-modify-write SPLIT across await\n'
        'actor Cache {\n'
        '    var items = [Item]()\n'
        '    func process() async {\n'
        '        let current = items      // READ\n'
        '        let new = await fetch()  // SUSPEND!\n'
        '        items = current + [new]  // WRITE (stale!)\n'
        '        // Call B can interleave at suspend --\n'
        '        // both read same state, last write wins,\n'
        '        // first caller\'s append is LOST\n'
        '    }\n'
        '}'
    )
    pdf.subsection("Fix: keep critical section atomic")
    pdf.code_block(
        '// GOOD: async work ABOVE, state update below\n'
        'func process() async {\n'
        '    let new = await fetch()  // suspend here\n'
        '    items.append(new)        // atomic read+write\n'
        '}\n'
        '\n'
        '// GOOD: state update ABOVE, async work below\n'
        'func enqueue(_ item: Item) async {\n'
        '    items.append(item)       // atomic read+write\n'
        '    await sync()             // suspend here\n'
        '}'
    )
    pdf.body_text(
        'Rule: critical section above OR below the await,\n'
        'never split across it. Each synchronous block on\n'
        'an actor is serialized -- no interleaving.'
    )

    # ── MAINACTOR ──
    pdf.section("MainActor Isolation")
    pdf.code_block(
        '// Entire class on main thread (ViewModels)\n'
        '@MainActor\n'
        'class ProfileVM: ObservableObject {\n'
        '    @Published var name = ""\n'
        '    func load() async throws {\n'
        '        // already on MainActor\n'
        '        name = try await api.fetchName()\n'
        '    }\n'
        '}'
    )
    pdf.code_block(
        '// One-off main thread hop\n'
        'await MainActor.run { self.label = "Done" }\n'
        '\n'
        '// Mark a function\n'
        '@MainActor func updateUI() { ... }\n'
        '\n'
        '// nonisolated: opt out for pure computation\n'
        'nonisolated func hash(into: inout Hasher) { }'
    )

    # ── SENDABLE ──
    pdf.section("Sendable")
    pdf.body_text(
        'Types safe to pass across actor/concurrency boundaries.'
    )
    pdf.code_block(
        '// Value types are implicitly Sendable\n'
        'struct Point: Sendable { var x, y: Double }\n'
        '\n'
        '// Classes must be final + immutable\n'
        'final class Token: Sendable {\n'
        '    let value: String  // let only, no var\n'
        '}\n'
        '\n'
        '// Actors are always Sendable\n'
        '// @Sendable closures: no mutable captures\n'
        'Task { @Sendable in\n'
        '    await process(item)  // item must be Sendable\n'
        '}'
    )
    pdf.body_text(
        '@unchecked Sendable: escape hatch when you\n'
        'manage thread safety yourself (e.g. with locks).'
    )

    # ── COOPERATIVE CANCELLATION ──
    pdf.section("Cooperative Cancellation")
    pdf.code_block(
        '// Check cancellation (throws if cancelled)\n'
        'try Task.checkCancellation()\n'
        '\n'
        '// Poll cancellation (non-throwing)\n'
        'guard !Task.isCancelled else { return partial }\n'
        '\n'
        '// withTaskCancellationHandler\n'
        'let data = try await withTaskCancellationHandler {\n'
        '    try await longDownload()\n'
        '} onCancel: {\n'
        '    urlSessionTask.cancel() // bridge to non-async\n'
        '}'
    )
    pdf.body_text(
        'Cancellation is cooperative -- tasks must check.\n'
        'URLSession, Task.sleep, etc. check automatically.'
    )

    # ── ASYNCSEQUENCE / ASYNCSTREAM ──
    pdf.section("AsyncSequence & AsyncStream")
    pdf.code_block(
        '// Consuming an AsyncSequence\n'
        'for await msg in webSocket.messages {\n'
        '    handle(msg)\n'
        '}\n'
        '\n'
        '// Creating a custom stream (replaces delegate)\n'
        'let stream = AsyncStream<CLLocation> { cont in\n'
        '    locMgr.onUpdate = { cont.yield($0) }\n'
        '    locMgr.onDone   = { cont.finish() }\n'
        '    cont.onTermination = { _ in\n'
        '        locMgr.stop()\n'
        '    }\n'
        '}'
    )
    pdf.code_block(
        '// AsyncThrowingStream for errors\n'
        'let s = AsyncThrowingStream<Data, Error> { c in\n'
        '    c.yield(data)\n'
        '    c.finish(throwing: err) // or c.finish()\n'
        '}'
    )
    pdf.body_text(
        'Use AsyncStream to bridge delegates, callbacks,\n'
        'NotificationCenter, KVO into async/await.'
    )

    # ── COMBINE RECIPES ──
    pdf.section("Combine Recipes")

    pdf.subsection("ViewModel + @Published + @StateObject")
    pdf.code_block(
        'import Combine\n'
        '\n'
        'class ProfileVM: ObservableObject {\n'
        '    @Published var name = ""\n'
        '    @Published var isLoading = false\n'
        '    private var cancellables = Set<AnyCancellable>()\n'
        '\n'
        '    func load() {\n'
        '        isLoading = true\n'
        '        api.fetchProfile()\n'
        '            .receive(on: DispatchQueue.main)\n'
        '            .sink(\n'
        '                receiveCompletion: { [weak self] _ in\n'
        '                    self?.isLoading = false\n'
        '                },\n'
        '                receiveValue: { [weak self] p in\n'
        '                    self?.name = p.name\n'
        '                }\n'
        '            )\n'
        '            .store(in: &cancellables)\n'
        '    }\n'
        '}\n'
        '\n'
        '// View\n'
        '@StateObject private var vm = ProfileVM()\n'
        'Text(vm.name)\n'
        '    .onAppear { vm.load() }'
    )

    pdf.subsection("Repository Publisher + AnyCancellable")
    pdf.code_block(
        'class UserRepo {\n'
        '    func fetchUser(id: Int)\n'
        '        -> AnyPublisher<User, Error> {\n'
        '        URLSession.shared\n'
        '            .dataTaskPublisher(for: url)\n'
        '            .map(\\.data)\n'
        '            .decode(type: User.self,\n'
        '                    decoder: JSONDecoder())\n'
        '            .eraseToAnyPublisher()\n'
        '    }\n'
        '}\n'
        '\n'
        '// Consumer\n'
        'var cancel: AnyCancellable?\n'
        'cancel = repo.fetchUser(id: 1)\n'
        '    .receive(on: DispatchQueue.main)\n'
        '    .sink(\n'
        '        receiveCompletion: { ... },\n'
        '        receiveValue: { user in ... }\n'
        '    )'
    )

    pdf.subsection("Search Debounce (classic pipeline)")
    pdf.code_block(
        '// In VM init -- react to @Published changes\n'
        '$searchText\n'
        '    .debounce(for: .milliseconds(300),\n'
        '             scheduler: RunLoop.main)\n'
        '    .removeDuplicates()\n'
        '    .sink { [weak self] query in\n'
        '        self?.performSearch(query)\n'
        '    }\n'
        '    .store(in: &cancellables)'
    )
    pdf.body_text(
        'Key operators: debounce, throttle, removeDuplicates,\n'
        'combineLatest, merge, map, compactMap, flatMap,\n'
        'receive(on:), eraseToAnyPublisher()'
    )

    # ── PAGINATED VIEWMODEL ──
    pdf.section("Paginated ViewModel (@Observable)")
    pdf.code_block(
        'enum LoadState {\n'
        '    case idle, loading, loaded, error, empty\n'
        '}\n'
        '\n'
        'protocol FetchItemsUseCase {\n'
        '    func execute(offset: Int, limit: Int)\n'
        '        async throws -> [Item]\n'
        '}'
    )
    pdf.code_block(
        '@Observable class PaginatedVM {\n'
        '    private(set) var items = [Item]()\n'
        '    private(set) var state: LoadState = .idle\n'
        '\n'
        '    private let useCase: FetchItemsUseCase\n'
        '    private var offset = 0\n'
        '    private let limit = 20\n'
        '    private var hasMore = true\n'
        '\n'
        '    init(useCase: FetchItemsUseCase) {\n'
        '        self.useCase = useCase\n'
        '    }\n'
        '\n'
        '    func loadNextPage() async {\n'
        '        guard state != .loading,\n'
        '              hasMore else { return }\n'
        '        state = .loading\n'
        '        do {\n'
        '            let page = try await useCase\n'
        '                .execute(offset: offset,\n'
        '                         limit: limit)\n'
        '            items += page\n'
        '            offset += page.count\n'
        '            hasMore = page.count == limit\n'
        '            state = items.isEmpty\n'
        '                ? .empty : .loaded\n'
        '        } catch {\n'
        '            state = .error\n'
        '        }\n'
        '    }\n'
        '}'
    )
    pdf.subsection("View (infinite scroll trigger)")
    pdf.code_block(
        'List(vm.items) { item in\n'
        '    Row(item: item)\n'
        '        .task {\n'
        '            if item.id == vm.items.last?.id {\n'
        '                await vm.loadNextPage()\n'
        '            }\n'
        '        }\n'
        '}\n'
        '.task { await vm.loadNextPage() }'
    )
    pdf.body_text(
        '@Observable (iOS 17+): no @Published needed.\n'
        'Guard prevents duplicate fetches & past-end loads.\n'
        'hasMore: false when page.count < limit.'
    )

    # ── Output ──
    out = os.path.join(os.path.dirname(__file__), "Swift_iOS_DSA_QuickRef.pdf")
    pdf.output(out)
    print(f"PDF written to {out}")


if __name__ == "__main__":
    build()
