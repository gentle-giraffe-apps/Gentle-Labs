import ProjectDescription

let project = Project(
    name: "ListDetail",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0"
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        .target(
            name: "ListDetail",
            destinations: .iOS,
            product: .app,
            bundleId: "com.example.ListDetail",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:]
            ]),
            sources: ["ListDetail/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "ListDetailTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.example.ListDetailTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["ListDetail/Tests/**"],
            dependencies: [
                .target(name: "ListDetail")
            ]
        )
    ]
)
