// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OblienKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v12),
    ],
    products: [
        .library(name: "OblienKit", targets: ["OblienKit"]),
    ],
    targets: [
        .target(name: "OblienKit"),
        .testTarget(name: "OblienKitTests", dependencies: ["OblienKit"]),
    ]
)
