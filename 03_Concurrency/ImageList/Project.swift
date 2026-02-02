import ProjectDescription

let project = Project(
    name: "ImageList",
    targets: [
        .target(
            name: "ImageList",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.jr.ImageList",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": true,
                ],
            ]),
            sources: ["ImageList/**"],
            resources: ["ImageList/Assets.xcassets"],
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
            name: "ImageListTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.jr.ImageListTests",
            deploymentTargets: .iOS("18.0"),
            sources: ["ImageListTests/**"],
            dependencies: [
                .target(name: "ImageList"),
            ]
        )
    ]
)
