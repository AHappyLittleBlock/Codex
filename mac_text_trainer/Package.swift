// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TextTrainer",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "TextTrainer", targets: ["TextTrainer"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "TextTrainer",
            dependencies: [],
            path: "Sources"
        )
    ]
)
