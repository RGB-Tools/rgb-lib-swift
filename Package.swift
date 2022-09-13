// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RgbLib",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RgbLib",
            targets: ["rgb_libFFI", "RgbLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(name: "rgb_libFFI", path: "./rgb_libFFI.xcframework"),
//        .binaryTarget(
//           name: "rgb_libFFI",
//           url: "https://github.com/RGB-Tools/rgb-lib-swift/releases/download/0.1.1/rgb_libFFI.xcframework.zip",
//           checksum: "ad1d34e4afae42636d6549cc3465fd23886e2aa0de609f943e3b444c22ecbf0b"),
        .target(
            name: "RgbLib",
            dependencies: ["rgb_libFFI"]),
    ]
)
