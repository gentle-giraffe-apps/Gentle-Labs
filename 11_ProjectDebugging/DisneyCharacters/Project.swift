import ProjectDescription

let project = Project(
    name: "DisneyCharacters",
    targets: [
        .target(
            name: "DisneyCharacters",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.jr.DisneyCharacters",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": true,
                ],
            ]),
            sources: ["DisneyCharacters/**"],
            resources: ["DisneyCharacters/Assets.xcassets"],
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
            name: "DisneyCharactersTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.jr.DisneyCharactersTests",
            deploymentTargets: .iOS("18.0"),
            sources: ["DisneyCharactersTests/**"],
            dependencies: [
                .target(name: "DisneyCharacters"),
            ]
        )
    ]
)
