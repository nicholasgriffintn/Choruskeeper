// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ChoruskeeperCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ChoruskeeperCore", targets: ["ChoruskeeperCore"])
    ],
    targets: [
        .target(
            name: "ChoruskeeperCore",
            path: "Choruskeeper/Core"
        ),
        .testTarget(
            name: "ChoruskeeperCoreTests",
            dependencies: ["ChoruskeeperCore"],
            path: "ChoruskeeperTests"
        )
    ]
)
