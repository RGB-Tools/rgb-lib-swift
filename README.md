# RGB Lib Swift bindings

This project builds a Swift library, `RgbLib`, for the [rgb-lib]
Rust library, which is included as a git submodule. The bindings are created by
the [rgb-lib-ffi] project, which is located inside the rgb-lib submodule.

## Usage

To use the Swift language bindings in your Xcode iOS or MacOS project add
its GitHub repository (https://github.com/RGB-Tools/rgb-lib-swift) and select
one of the release versions.
Then link the C++ library by going to
`Build Phases -> Link Binary With Libraries -> Add items (+)` and adding
`libc++.tbd`.
You may then import and use the `RgbLib` library in your Swift code.

## Build and publish

If you are a maintainer of this project or want to build and publish this
project to your own Github repository use the following steps:

```shell
# Update the submodule
git submodule update --init

# Generate the bindings and FFI ZIP
./generate.sh
```

Then update the `Package.swift` file with the new expected URL for the ZIP
file and new checksum as shown at the end of the `generate.sh` script.
For example:
```swift
.binaryTarget(
   name: "rgb_libFFI",
   url: "https://github.com/RGB-Tools/rgb-lib-swift/releases/download/0.1.9/rgb_libFFI.xcframework.zip",
   checksum: "c1bb14396b87077689b7c74e1774ddd55443d826264737a20b5c5a9d931b48e0"),
```

Commit the changed `Package.swift` file, then tag the commit with the new
version number.

Finally, create a GitHub release for your new tag and upload the newly created
ZIP to the new GitHub release and publish the release.

Now you can test the new package in Xcode.
If you get an error you might need to reset the Xcode package caches:
`File -> Packages -> Reset Package Caches`.


[rgb-lib]: https://github.com/RGB-Tools/rgb-lib
[rgb-lib-ffi]: https://github.com/RGB-Tools/rgb-lib/tree/master/rgb-lib-ffi
