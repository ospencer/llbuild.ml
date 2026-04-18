#!/bin/sh
set -eu

mkdir -p "$cur__install/bin"

install_from() {
  ln -sf "$1" "$cur__install/bin/pkg-config"
}

for prog in pkg-config pkgconf pkg-config.exe pkgconf.exe; do
  if command -v "$prog" >/dev/null 2>&1; then
    install_from "$(command -v "$prog")"
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

# Fallback shim: when no real pkg-config is available, emit values from
# PKG_CONFIG_PATH-provided .pc files using plain shell. Covers the common
# use in dune-configurator's Pkg_config.query.
cat > "$cur__install/bin/pkg-config" <<'SHIM'
#!/bin/sh
want_cflags=0
want_libs=0
want_exists=0
package=""
for arg in "$@"; do
  case "$arg" in
    --cflags) want_cflags=1 ;;
    --libs) want_libs=1 ;;
    --exists) want_exists=1 ;;
    --modversion|--version|--print-errors|--silence-errors|--short-errors|--static) ;;
    -*) ;;
    *) package="$arg" ;;
  esac
done

if [ -z "$package" ]; then
  exit 0
fi

pc_file=""
OLDIFS=$IFS
IFS=':'
for dir in $PKG_CONFIG_PATH; do
  if [ -f "$dir/$package.pc" ]; then
    pc_file="$dir/$package.pc"
    break
  fi
done
IFS=$OLDIFS

if [ -z "$pc_file" ]; then
  exit 1
fi

if [ "$want_exists" = "1" ]; then
  exit 0
fi

eval_pc() {
  awk -v want="$1" '
    /^[A-Za-z_][A-Za-z0-9_]*=/ {
      split($0, a, "=")
      name = a[1]
      val = substr($0, length(name) + 2)
      vars[name] = val
      next
    }
    /^[A-Za-z]+:/ {
      key = $1
      sub(/^[^:]+:[ \t]*/, "", $0)
      rest = $0
      if (key == want ":") {
        while (match(rest, /\$\{[A-Za-z_][A-Za-z0-9_]*\}/)) {
          varname = substr(rest, RSTART + 2, RLENGTH - 3)
          rest = substr(rest, 1, RSTART - 1) vars[varname] substr(rest, RSTART + RLENGTH)
        }
        print rest
      }
    }
  ' "$2"
}

if [ "$want_cflags" = "1" ]; then
  eval_pc "Cflags" "$pc_file"
fi
if [ "$want_libs" = "1" ]; then
  eval_pc "Libs" "$pc_file"
fi
SHIM
chmod +x "$cur__install/bin/pkg-config"
