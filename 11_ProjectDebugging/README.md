# 11_ProjectDebugging

Sample projects designed as debugging exercises. Each project is a fully functional app with intentional bugs introduced for practice.

## Contents

| Folder | Description |
|--------|-------------|
| `DisneyCharacters` | SwiftUI MVVM app using the Disney Characters API with pagination and search |

---

## DisneyCharacters

A SwiftUI app that browses Disney characters with pagination, pull-to-refresh, and debounced local search.

### Data Flow

```
DisneyCharactersApp
  └─ CharacterListView          (SwiftUI — drives UI from ViewModel state)
       ├─ CharacterListViewModel (loads pages, filters locally, debounces search)
       │    └─ CharacterService  (protocol — fetches from network or mock)
       └─ CharacterDetailView    (read-only detail with flow-layout tags)
```

### File Map

```
DisneyCharacters/
├── App/
│   └── DisneyCharactersApp.swift      — Entry point, wires NetworkCharacterService
├── Data/
│   ├── Models.swift                   — ContentLoadingState, CharacterResponse, DisneyCharacter
│   └── CharacterService.swift         — Protocol + 4 implementations (Network, Mock, Empty, Failing)
└── Presentation/
    ├── CharacterListView.swift        — List with infinite scroll, search, pull-to-refresh
    ├── CharacterListViewModel.swift   — @Observable VM — pagination, filtering, debounce
    └── CharacterDetailView.swift      — Scrollable detail with flow-layout tags
```

### Service Variants

| Service | Purpose |
|---------|---------|
| `NetworkCharacterService` | Live API calls to `api.disneyapi.dev` |
| `MockCharacterService` | Deterministic fake data with simulated latency |
| `EmptyCharacterService` | Returns zero results — tests empty state |
| `FailingCharacterService` | Always throws — tests error state |

All four are wired up as SwiftUI `#Preview`s in `CharacterListView.swift`.
