#!/bin/sh
set -eu

mkdir -p "$cur__install/bin"

install_from() {
  ln -sf "$1" "$cur__install/bin/pkg-config" 2>/dev/null || cp "$1" "$cur__install/bin/pkg-config"
}

for prog in pkg-config.exe pkg-config pkgconf.exe pkgconf; do
  if command -v "$prog" >/dev/null 2>&1; then
    install_from "$(command -v "$prog")"
    case "$prog" in
      *.exe) cp -f "$(command -v "$prog")" "$cur__install/bin/pkg-config.exe" ;;
    esac
    exit 0
  fi
done

for dir in /opt/homebrew/bin /usr/local/bin /usr/bin /bin; do
  for name in pkg-config pkgconf; do
    if [ -x "$dir/$name" ]; then
      install_from "$dir/$name"
      exit 0
    fi
  done
done

case "$(uname -s)" in
  CYGWIN*|MINGW*|MSYS*)
    PKGCFG_URL="https://downloads.sourceforge.net/project/pkgconfiglite/0.28-1/pkg-config-lite-0.28-1_bin-win32.zip"
    work="$cur__install/_pkgcfg"
    mkdir -p "$work"
    curl -sL "$PKGCFG_URL" -o "$work/pkgcfg.zip"
    (cd "$work" && unzip -q pkgcfg.zip)
    exe="$(find "$work" -name pkg-config.exe | head -1)"
    if [ -n "$exe" ]; then
      cp "$exe" "$cur__install/bin/pkg-config.exe"
      cp "$exe" "$cur__install/bin/pkg-config"
      exit 0
    fi
    ;;
esac

echo "warn: pkg-config not found and no bundled fallback; downstream builds may fail" >&2
exit 0
