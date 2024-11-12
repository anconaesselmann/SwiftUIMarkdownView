// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIMarkdownView",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftUIMarkdownView",
            targets: ["SwiftUIMarkdownView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.1.0"),
        .package(url: "https://github.com/anconaesselmann/LoadableView", from: "0.9.2"),
    ],
    targets: [
        .target(
            name: "SwiftUIMarkdownView",
            dependencies: ["Splash", "LoadableView"]
        ),
    ]
)
