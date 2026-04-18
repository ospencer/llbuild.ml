#!/bin/sh
set -eu

mkdir -p "$cur__install/bin"

for dir in /opt/homebrew/bin /usr/local/bin /usr/bin /bin; do
  if [ -x "$dir/cmake" ]; then
    ln -sf "$dir/cmake" "$cur__install/bin/cmake"
    exit 0
  fi
done

if command -v cmake >/dev/null 2>&1; then
  ln -sf "$(command -v cmake)" "$cur__install/bin/cmake"
  exit 0
fi

echo "error: cmake not found" >&2
exit 1
