// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "WifiQrConnect",
    platforms: [
        .macOS(.v14),
    ],
    targets: [
        .executableTarget(
            name: "WifiQrConnect",
            path: "Sources/WifiQrConnect",
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "WifiQrConnectTests",
            dependencies: ["WifiQrConnect"],
            path: "Tests/WifiQrConnectTests"
        ),
    ]
)
