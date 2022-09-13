#!/usr/bin/env bash

set -euo pipefail

RGBLIBFFI_PATH="./rgb-lib/rgb-lib-ffi"
MANIFEST_PATH=(--manifest-path "$RGBLIBFFI_PATH/Cargo.toml")
XCFRAMEWORK_PATH="rgb_libFFI.xcframework"

rm -rf "${XCFRAMEWORK_PATH:?}/*/"

echo "Generating Swift bindings..."
cargo run "${MANIFEST_PATH[@]}" \
  --package rgb-lib-ffi-bindgen -- \
  --language swift --udl-file $RGBLIBFFI_PATH/src/rgb-lib.udl \
  --out-dir ./Sources/RgbLib
mv Sources/RgbLib/rgb_lib.swift Sources/RgbLib/RgbLib.swift

echo "Building rgb-lib-ffi libs for Apple targets..."
TARGET_TRIPLES=("x86_64-apple-darwin" "aarch64-apple-darwin" "x86_64-apple-ios" "aarch64-apple-ios")
for target in "${TARGET_TRIPLES[@]}"; do
  echo "Build rgb-lib-ffi lib for target $target"
  cargo build "${MANIFEST_PATH[@]}" --target "$target"
done
# special build for M1 ios simulator
cargo +nightly build -Z build-std \
  "${MANIFEST_PATH[@]}" --target aarch64-apple-ios-sim

echo "Create lipo static libs for ios-sim to support M1"
mkdir -p $RGBLIBFFI_PATH/target/lipo-ios-sim/debug
lipo $RGBLIBFFI_PATH/target/aarch64-apple-ios-sim/debug/librgblibffi.a \
  $RGBLIBFFI_PATH/target/x86_64-apple-ios/debug/librgblibffi.a -create \
  -output $RGBLIBFFI_PATH/target/lipo-ios-sim/debug/librgblibffi.a

echo "Create lipo static libs for macos to support M1"
mkdir -p $RGBLIBFFI_PATH/target/lipo-macos/debug
lipo $RGBLIBFFI_PATH/target/aarch64-apple-darwin/debug/librgblibffi.a \
  $RGBLIBFFI_PATH/target/x86_64-apple-darwin/debug/librgblibffi.a -create \
  -output $RGBLIBFFI_PATH/target/lipo-macos/debug/librgblibffi.a

XCFRAMEWORK_LIBS=("ios-arm64" "ios-arm64_x86_64-simulator" "macos-arm64_x86_64")
for lib in "${XCFRAMEWORK_LIBS[@]}"; do
    framework="$XCFRAMEWORK_PATH/$lib/rgb_libFFI.framework"
    headers="$framework/Headers"
    modules="$framework/Modules"
    mkdir -p "$headers" "$modules"
    cp Sources/RgbLib/rgb_libFFI.h "$headers/"

    cat << EOF > "$headers/rgb_libFFI-umbrella.h"
// This is the "umbrella header" for our combined Rust code library.
// It needs to import all of the individual headers.

#import "rgb_libFFI.h"
EOF

    cat << EOF > "$modules/module.modulemap"
framework module rgb_libFFI {
  umbrella header "rgb_libFFI-umbrella.h"

  export *
  module * { export * }
}
EOF

done

echo "Copy librgblibffi.a files to $XCFRAMEWORK_PATH/rgb_libFFI"
cp $RGBLIBFFI_PATH/target/aarch64-apple-ios/debug/librgblibffi.a $XCFRAMEWORK_PATH/ios-arm64/rgb_libFFI.framework/rgb_libFFI
cp $RGBLIBFFI_PATH/target/lipo-ios-sim/debug/librgblibffi.a $XCFRAMEWORK_PATH/ios-arm64_x86_64-simulator/rgb_libFFI.framework/rgb_libFFI
cp $RGBLIBFFI_PATH/target/lipo-macos/debug/librgblibffi.a $XCFRAMEWORK_PATH/macos-arm64_x86_64/rgb_libFFI.framework/rgb_libFFI

# remove unneed .h and .modulemap files
rm Sources/RgbLib/rgb_libFFI.h
rm Sources/RgbLib/rgb_libFFI.modulemap

if test -f "$XCFRAMEWORK_PATH.zip"; then
    echo "Remove old $XCFRAMEWORK_PATH.zip"
    rm $XCFRAMEWORK_PATH.zip
fi

# zip package directory into a bundle for distribution
zip -9 -r $XCFRAMEWORK_PATH.zip $XCFRAMEWORK_PATH

# compute $XCFRAMEWORK_PATH.zip checksum
echo checksum:
swift package compute-checksum $XCFRAMEWORK_PATH.zip
