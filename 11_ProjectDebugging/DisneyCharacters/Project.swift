import ProjectDescription

let project = Project(
    name: "DisneyCharacters",
    packages: [
        .remote(url: "https://github.com/gentle-giraffe-apps/SmartAsyncImage.git", requirement: .upToNextMinor(from: "0.1.2")),
    ],
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
            resources: [
                "DisneyCharacters/Assets.xcassets",
                "DisneyCharacters/Data/all_characters.json",
            ],
            dependencies: [
                .package(product: "SmartAsyncImage", type: .runtime),
            ],
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
