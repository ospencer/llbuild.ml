# llbuild.ml

OCaml bindings for [llbuild](https://github.com/swiftlang/swift-llbuild), a low-level build system.

## Overview

llbuild.ml provides a typed OCaml interface to llbuild's C API via [ctypes](https://github.com/yallop/ocaml-ctypes).

### Supported platforms

- macOS
- Linux
- Windows (mingw64)


### Build requirements

- OCaml >= 4.14
- CMake
- Clang (macOS/Linux) or MinGW (Windows)
- libffi
- ncurses (macOS/Linux)

## Usage

```ocaml
open Llbuild

let () =
  let engine =
    Engine.create
      {
        lookup_rule =
          (fun key ->
            {
              start = (fun ti -> Engine.Task_interface.request_input ti "dep" 1);
              provide_value = (fun _ti ~input_id:_ _value -> ());
              inputs_available =
                (fun ti ->
                  Engine.Task_interface.complete ti "result" ~force_change:false);
            });
        error = (fun msg -> Printf.eprintf "error: %s\n" msg);
        cycle_detected = (fun _keys -> ());
      }
  in
  let result = Engine.build engine "my-key" in
  Printf.printf "Build result: %s\n" result;
  Engine.destroy engine
```

## API

The binding covers the following modules:

- **`Llbuild.Engine`** — Core build engine with rule lookup delegates, task interfaces for requesting inputs and completing tasks, and database-backed incremental builds
- **`Llbuild.Build_key`** — Typed build keys (commands, custom tasks, nodes, directories, targets, stats)
- **`Llbuild.Build_value`** — Build result values with constructors for each outcome kind
- **`Llbuild.Database`** — Direct database access with epoch tracking
- **`Llbuild.Quality_of_service`** — Thread QoS configuration
- **`Llbuild.Tracing`** — Enable/disable build tracing
- **`Llbuild.Diagnostic_kind`** — Note, warning, and error diagnostics
- **`Llbuild.Data`** — Opaque byte buffer type used throughout the API

## Testing

```sh
esy test
```

