#!/bin/sh
set -e

copy_from() {
  src_prefix="$1"
  mkdir -p "$cur__install/include" "$cur__install/lib" "$cur__install/lib/pkgconfig"
  cp "$src_prefix"/include/ffi*.h "$cur__install/include/" 2>/dev/null || true
  cp "$src_prefix"/lib/libffi*.a "$cur__install/lib/" 2>/dev/null || true
  cp "$src_prefix"/lib/libffi*.dylib "$cur__install/lib/" 2>/dev/null || true
  cp "$src_prefix"/lib/libffi*.so* "$cur__install/lib/" 2>/dev/null || true
  if [ -f "$src_prefix/lib/pkgconfig/libffi.pc" ]; then
    cp "$src_prefix/lib/pkgconfig/libffi.pc" "$cur__install/lib/pkgconfig/"
  fi
}

case "$(uname -s)" in
  Darwin)
    BREW_PREFIX="$(brew --prefix libffi 2>/dev/null || echo /opt/homebrew/opt/libffi)"
    if [ -d "$BREW_PREFIX/include" ]; then
      copy_from "$BREW_PREFIX"
    else
      echo "error: libffi not found via brew — run: brew install libffi" >&2
      exit 1
    fi
    ;;
  CYGWIN*|MINGW*|MSYS*)
    LIBFFI_VERSION=3.4.6
    curl -sL "https://github.com/libffi/libffi/releases/download/v${LIBFFI_VERSION}/libffi-${LIBFFI_VERSION}.tar.gz" | tar xz
    cd "libffi-${LIBFFI_VERSION}"
    MAKEINFO=true ./configure --host=x86_64-w64-mingw32 --prefix="$cur__install" --disable-docs
    MAKEINFO=true make -j4
    make install
    ;;
  *)
    for prefix in /usr /usr/local; do
      if [ -f "$prefix/include/ffi.h" ]; then
        copy_from "$prefix"
        exit 0
      fi
    done
    for ffi_h in /usr/include/*/ffi.h; do
      if [ -f "$ffi_h" ]; then
        arch_dir="$(dirname "$ffi_h")"
        arch_name="$(basename "$arch_dir")"
        mkdir -p "$cur__install/include" "$cur__install/lib" "$cur__install/lib/pkgconfig"
        cp "$arch_dir"/ffi*.h "$cur__install/include/"
        cp /usr/lib/"$arch_name"/libffi*.so* "$cur__install/lib/" 2>/dev/null || true
        cp /usr/lib/"$arch_name"/libffi*.a "$cur__install/lib/" 2>/dev/null || true
        if [ -f "/usr/lib/$arch_name/pkgconfig/libffi.pc" ]; then
          cp "/usr/lib/$arch_name/pkgconfig/libffi.pc" "$cur__install/lib/pkgconfig/"
        fi
        exit 0
      fi
    done
    echo "error: libffi headers not found" >&2
    exit 1
    ;;
esac
