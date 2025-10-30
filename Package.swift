// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "maker",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "maker", targets: ["maker"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "maker",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
