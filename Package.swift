// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "KillSnailCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "KillSnailCore", targets: ["KillSnailCore"])
    ],
    targets: [
        .target(
            name: "KillSnailCore",
            path: "KillSnailCore"
        ),
        .testTarget(
            name: "KillSnailCoreTests",
            dependencies: ["KillSnailCore"],
            path: "KillSnailTests"
        )
    ]
)
