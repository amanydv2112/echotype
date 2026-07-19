// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EchoType",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "EchoType", targets: ["EchoType"]),
        .library(name: "EchoTypeCore", targets: ["EchoTypeCore"])
    ],
    targets: [
        .target(
            name: "CSQLite",
            path: "Sources/CSQLite",
            publicHeadersPath: "include"
        ),
        .target(
            name: "EchoTypeCore",
            dependencies: ["CSQLite"],
            path: "Sources/EchoTypeCore",
            linkerSettings: [
                .linkedLibrary("sqlite3")
            ]
        ),
        .executableTarget(
            name: "EchoType",
            dependencies: ["EchoTypeCore"],
            path: "Sources/EchoType"
        ),
        .executableTarget(
            name: "EchoTypeCoreSmokeTests",
            dependencies: ["EchoTypeCore"],
            path: "Tests/EchoTypeCoreSmokeTests"
        ),
        .executableTarget(
            name: "EchoTypeRecorderSmokeTests",
            dependencies: ["EchoTypeCore"],
            path: "Tests/EchoTypeRecorderSmokeTests"
        )
    ]
)
