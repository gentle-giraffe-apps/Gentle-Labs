import ProjectDescription

let project = Project(
    name: "AsyncRecipes",
    packages: [
        .remote(
            url: "https://github.com/apple/swift-async-algorithms",
            requirement: .upToNextMajor(from: "1.0.0")
        ),
    ],
    targets: [
        .target(
            name: "AsyncRecipes",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.jr.AsyncRecipes",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
            ]),
            sources: ["AsyncRecipes/**"],
            dependencies: [
                .package(product: "AsyncAlgorithms"),
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
    ]
)
