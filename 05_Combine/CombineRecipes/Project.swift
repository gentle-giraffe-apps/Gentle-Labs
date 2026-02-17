import ProjectDescription

let project = Project(
    name: "CombineRecipes",
    targets: [
        .target(
            name: "CombineRecipes",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.jr.CombineRecipes",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
            ]),
            sources: ["CombineRecipes/**"],
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
            name: "CombineRecipesTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.jr.CombineRecipesTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["CombineRecipesTests/**"],
            dependencies: [
                .target(name: "CombineRecipes"),
            ]
        ),
    ]
)
