// swift-tools-version:6.0
//
// Proxy-only vendored swiftmaestro runtime for AdaptiveCards-Mobile.
// Vendored from hggz/swiftmaestro as of 2026-07-12. All library backends are
// retained; only the ArgumentParser CLI and repository-specific harnesses are
// omitted, matching sibling bridge drops that publish libraries without a CLI.

import PackageDescription

// `platforms` only narrows the Apple host minimum. Linux and Windows build
// without platform clauses. swiftmaestro is host-side automation: it drives
// iOS remotely through WDA/Appium but does not execute inside an iOS app.
let package = Package(
    name: "swiftmaestro",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "SwiftMaestroFlow", targets: ["SwiftMaestroFlow"]),
        .library(name: "SwiftMaestroDriver", targets: ["SwiftMaestroDriver"]),
        .library(name: "SwiftMaestroReport", targets: ["SwiftMaestroReport"]),
        .library(name: "SwiftMaestroJS", targets: ["SwiftMaestroJS"]),
        .library(name: "SwiftMaestroRunner", targets: ["SwiftMaestroRunner"]),
        .library(name: "SwiftMaestroBrowser", targets: ["SwiftMaestroBrowser"]),
        .library(name: "SwiftMaestroDeviceLab", targets: ["SwiftMaestroDeviceLab"]),
        .library(name: "SwiftMaestroWDA", targets: ["SwiftMaestroWDA"]),
        .library(name: "SwiftMaestroAppium", targets: ["SwiftMaestroAppium"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        // Public hggz Windows-MSVC substrate. Direct root declarations make
        // these identities override AsyncHTTPClient's Apple NIO transitive deps.
        .package(url: "https://github.com/hggz/swift-nio.git",
                 revision: "7c9c6861c968f8902c0610ab4ba2e23311f5092c"),
        .package(url: "https://github.com/hggz/swift-nio-extras.git",
                 revision: "076c9b493c6fe365ba42663fc16c4239d17dfb92"),
        .package(url: "https://github.com/hggz/swift-nio-ssl.git",
                 revision: "7f9efd53d9d4d916f8fb4ba77646ada440b6fee8"),
        .package(url: "https://github.com/hggz/async-http-client.git",
                 revision: "eaaf46acd43c9076f3e00759a05dd5de7978db36"),
        .package(url: "https://github.com/hggz/websocket-kit.git",
             revision: "ddfba8cf33fd420fd27360ab30907cefee1de0f2"),
    ],
    targets: [
        .target(
            name: "SwiftMaestroFlow",
            dependencies: [.product(name: "Yams", package: "Yams")]
        ),
        .target(name: "SwiftMaestroReport"),
        .target(
            name: "SwiftMaestroProcess",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "SwiftMaestroDriver",
            dependencies: [
                "SwiftMaestroFlow",
                "SwiftMaestroProcess",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ]
        ),
        .target(
            name: "SwiftMaestroBrowser",
            dependencies: [
                "SwiftMaestroFlow", "SwiftMaestroDriver", "SwiftMaestroProcess",
                .product(name: "WebSocketKit", package: "websocket-kit"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "SwiftMaestroDeviceLab",
            dependencies: [
                "SwiftMaestroFlow", "SwiftMaestroDriver", "SwiftMaestroProcess",
                .product(name: "WebSocketKit", package: "websocket-kit"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "SwiftMaestroWDA",
            dependencies: [
                "SwiftMaestroFlow", "SwiftMaestroDriver", "SwiftMaestroProcess",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "SwiftMaestroAppium",
            dependencies: [
                "SwiftMaestroFlow", "SwiftMaestroDriver", "SwiftMaestroWDA",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "SwiftMaestroJSEngine",
            publicHeadersPath: "include"
        ),
        .target(
            name: "SwiftMaestroJS",
            dependencies: [
                "SwiftMaestroJSEngine",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "SwiftMaestroRunner",
            dependencies: [
                "SwiftMaestroFlow",
                "SwiftMaestroDriver",
                "SwiftMaestroReport",
                "SwiftMaestroJS",
            ]
        ),
        .testTarget(
            name: "SwiftMaestroFlowTests",
            dependencies: ["SwiftMaestroFlow"],
            exclude: ["Fixtures"]
        ),
        .testTarget(
            name: "SwiftMaestroDriverTests",
            dependencies: [
                "SwiftMaestroDriver", "SwiftMaestroFlow", "SwiftMaestroProcess",
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ],
            exclude: ["Fixtures"]
        ),
        .testTarget(
            name: "SwiftMaestroReportTests",
            dependencies: ["SwiftMaestroReport"],
            exclude: ["Goldens"]
        ),
        .testTarget(
            name: "SwiftMaestroJSTests",
            dependencies: [
                "SwiftMaestroJS",
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "SwiftMaestroProcessTests",
            dependencies: ["SwiftMaestroProcess"]
        ),
        .testTarget(
            name: "SwiftMaestroBrowserTests",
            dependencies: [
                "SwiftMaestroBrowser", "SwiftMaestroDriver", "SwiftMaestroFlow",
                "SwiftMaestroProcess",
                .product(name: "WebSocketKit", package: "websocket-kit"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "SwiftMaestroDeviceLabTests",
            dependencies: [
                "SwiftMaestroDeviceLab", "SwiftMaestroDriver", "SwiftMaestroFlow",
                "SwiftMaestroProcess",
                .product(name: "WebSocketKit", package: "websocket-kit"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "SwiftMaestroWDATests",
            dependencies: [
                "SwiftMaestroWDA", "SwiftMaestroDriver", "SwiftMaestroFlow",
                "SwiftMaestroProcess",
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ],
            exclude: ["Fixtures"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "SwiftMaestroAppiumTests",
            dependencies: [
                "SwiftMaestroAppium", "SwiftMaestroDriver", "SwiftMaestroFlow",
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ],
            exclude: ["Fixtures"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "SwiftMaestroRunnerTests",
            dependencies: [
                "SwiftMaestroRunner",
                "SwiftMaestroDriver",
                "SwiftMaestroFlow",
                "SwiftMaestroReport",
            ],
            exclude: ["Fixtures"]
        ),
    ]
)
