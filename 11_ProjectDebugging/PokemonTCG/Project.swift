import ProjectDescription

let project = Project(
    name: "PokemonTCG",
    targets: [
        .target(
            name: "PokemonTCG",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.jr.PokemonTCG",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": true,
                ],
            ]),
            sources: ["PokemonTCG/**"],
            resources: ["PokemonTCG/Assets.xcassets"],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "HGE6ZKLW3Q",
                    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                ],
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release"),
                ]
            )
        ),
        .target(
            name: "PokemonTCGTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.jr.PokemonTCGTests",
            deploymentTargets: .iOS("18.0"),
            sources: ["PokemonTCGTests/**"],
            dependencies: [
                .target(name: "PokemonTCG"),
            ]
        )
    ]
)
