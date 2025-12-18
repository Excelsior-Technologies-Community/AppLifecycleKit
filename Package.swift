// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppLifecycleKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AppLifecycleKit",
            targets: ["AppLifecycleKit"]
        )
    ],
    targets: [
        .target(
            name: "AppLifecycleKit",
            path: "Sources/AppLifecycleKit"
        ),
        .testTarget(
            name: "AppLifecycleKitTests",
            dependencies: ["AppLifecycleKit"]
        )
    ]
)
