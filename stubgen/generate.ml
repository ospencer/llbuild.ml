let () =
  let prefix = "llbuild" in
  match Sys.argv.(1) with
  | "c" ->
    Format.printf "#include \"llbuild.h\"@.";
    Cstubs.write_c Format.std_formatter ~prefix
      (module Llbuild_ffi.Function_description.Functions)
  | "ml" ->
    Cstubs.write_ml Format.std_formatter ~prefix
      (module Llbuild_ffi.Function_description.Functions)
  | s -> failwith ("unknown mode: " ^ s)
  | exception Invalid_argument _ ->
    failwith "usage: generate [c|ml]"
