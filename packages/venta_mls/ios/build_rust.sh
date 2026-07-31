#!/usr/bin/env bash
#
# Builds the Rust MLS engine for whichever iOS platform Xcode is currently
# building, and leaves one static archive at ios/build/libventa_mls.a for the
# podspec's -force_load to pick up.
#
# Only the architectures Xcode actually asked for are built. Building the union
# every time and lipo-ing costs a full extra compile of openmls per run, which
# is by far the slowest thing in this package.
set -euo pipefail

cd "$(dirname "$0")"
RUST_DIR="../rust"
OUT_DIR="build"
mkdir -p "$OUT_DIR"

if ! command -v cargo >/dev/null 2>&1; then
  # Xcode's build environment does not source the user's shell profile, so a
  # rustup install that works in Terminal is invisible here.
  export PATH="$HOME/.cargo/bin:$PATH"
fi
if ! command -v cargo >/dev/null 2>&1; then
  echo "error: cargo not found. Install Rust (https://rustup.rs) - the MLS engine is native code." >&2
  exit 1
fi

# Debug builds of openmls are slow enough to notice on every launch; the crate
# has no debug-only behaviour worth that, so release is used throughout.
PROFILE="release"

targets=()
case "${PLATFORM_NAME:-iphoneos}" in
  iphonesimulator)
    for arch in ${ARCHS:-arm64}; do
      case "$arch" in
        arm64) targets+=("aarch64-apple-ios-sim") ;;
        x86_64) targets+=("x86_64-apple-ios") ;;
      esac
    done
    ;;
  *)
    targets+=("aarch64-apple-ios")
    ;;
esac

built=()
for target in "${targets[@]}"; do
  rustup target add "$target" >/dev/null 2>&1 || true
  echo "venta_mls: building $target"
  ( cd "$RUST_DIR" && cargo build --release --target "$target" )
  built+=("$RUST_DIR/target/$target/$PROFILE/libventa_mls.a")
done

if [ "${#built[@]}" -eq 1 ]; then
  cp "${built[0]}" "$OUT_DIR/libventa_mls.a"
else
  # Simulator only: arm64-sim and x86_64-sim are the one pair that may legally
  # share an archive. Device and simulator slices never can.
  lipo -create "${built[@]}" -output "$OUT_DIR/libventa_mls.a"
fi

echo "venta_mls: wrote $OUT_DIR/libventa_mls.a"
