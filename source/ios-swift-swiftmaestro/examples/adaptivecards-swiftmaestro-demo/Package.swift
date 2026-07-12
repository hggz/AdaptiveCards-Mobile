// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AdaptiveCardsSwiftMaestroDemo",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(name: "swiftmaestro", path: "../.."),
        // Repeat the public dependency roots so this independent demo graph
        // resolves the Windows-capable hggz NIO identities transitively.
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/hggz/swift-nio.git",
                 revision: "7c9c6861c968f8902c0610ab4ba2e23311f5092c"),
        .package(url: "https://github.com/hggz/swift-nio-extras.git",
                 revision: "076c9b493c6fe365ba42663fc16c4239d17dfb92"),
        .package(url: "https://github.com/hggz/swift-nio-ssl.git",
                 revision: "7f9efd53d9d4d916f8fb4ba77646ada440b6fee8"),
        .package(url: "https://github.com/hggz/async-http-client.git",
                 revision: "eaaf46acd43c9076f3e00759a05dd5de7978db36"),
    ],
    targets: [
        .executableTarget(
            name: "AdaptiveCardsDemo",
            dependencies: [
                .product(name: "SwiftMaestroFlow", package: "swiftmaestro"),
                .product(name: "SwiftMaestroDriver", package: "swiftmaestro"),
                .product(name: "SwiftMaestroReport", package: "swiftmaestro"),
                .product(name: "SwiftMaestroRunner", package: "swiftmaestro"),
            ]
        ),
    ]
)
