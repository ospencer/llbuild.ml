#!/bin/sh
set -eu

mkdir -p "$cur__install/bin"

link_to() {
  target="$1"
  name="$2"
  ln -sf "$target" "$cur__install/bin/$name" 2>/dev/null || cp "$target" "$cur__install/bin/$name"
}

for prog in cmake cmake.exe; do
  if command -v "$prog" >/dev/null 2>&1; then
    path="$(command -v "$prog")"
    link_to "$path" "$prog"
    exit 0
  fi
done

for dir in \
  /opt/homebrew/bin \
  /usr/local/bin \
  /usr/bin \
  /bin \
  "/cygdrive/c/Program Files/CMake/bin" \
  "/cygdrive/c/Program Files (x86)/CMake/bin"; do
  for prog in cmake cmake.exe; do
    if [ -x "$dir/$prog" ]; then
      link_to "$dir/$prog" "$prog"
      exit 0
    fi
  done
done

echo "warn: cmake not found on PATH; downstream builds must find it themselves" >&2
exit 0
