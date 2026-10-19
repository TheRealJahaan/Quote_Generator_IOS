// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuoteKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "QuoteKit", targets: ["QuoteKit"])
    ],
    targets: [
        .target(name: "QuoteKit"),
        .testTarget(name: "QuoteKitTests", dependencies: ["QuoteKit"])
    ]
)
