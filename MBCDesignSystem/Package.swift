// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MBCDesignSystem",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "MBCDesignSystem", targets: ["MBCDesignSystem"]),
    ],
    targets: [
        .target(
            name: "MBCDesignSystem",
            path: "Sources/MBCDesignSystem"
        ),
        .testTarget(
            name: "MBCDesignSystemTests",
            dependencies: ["MBCDesignSystem"],
            path: "Tests/MBCDesignSystemTests"
        ),
    ]
)
