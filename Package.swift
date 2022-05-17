// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "GraphQL",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GraphQLLib",
            targets: ["GraphQL"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "GraphQL",
            path: "Sources"),
        .testTarget(
            name: "GraphQLTests",
            dependencies: ["GraphQL"],
            path: "Tests")
    ]
)
