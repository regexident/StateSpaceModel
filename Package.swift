// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StateSpaceModel",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "StateSpaceModel",
            targets: [
                "StateSpaceModel",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/regexident/StateSpace", .branch("master")),
        .package(url: "https://github.com/jounce/Surge", from: "2.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "StateSpaceModel",
            dependencies: [
                "StateSpace",
                "Surge",
            ]
        ),
        .testTarget(
            name: "StateSpaceModelTests",
            dependencies: [
                "StateSpaceModel",
            ]
        ),
    ]
)
