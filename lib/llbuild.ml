open Ctypes
module C = Llbuild_ffi.Function_description.Functions (Llbuild_generated)
module T = Llbuild_ffi.Type_description

let get_version () = C.llb_get_full_version_string ()
let get_api_version () = C.llb_get_api_version ()

module Data = struct
  type t = string

  let of_string s = s
  let to_string s = s

  let to_llb_data s =
    let len = String.length s in
    let d = make T.llb_data in
    setf d T.llb_data_length (Unsigned.UInt64.of_int len);
    let buf = CArray.make uint8_t len in
    String.iteri
      (fun i c -> CArray.set buf i (Unsigned.UInt8.of_int (Char.code c)))
      s;
    setf d T.llb_data_data (CArray.start buf);
    (d, buf)

  let of_llb_data d =
    let len = Unsigned.UInt64.to_int (getf d T.llb_data_length) in
    let data = getf d T.llb_data_data in
    let data_char = coerce (ptr uint8_t) (ptr char) data in
    String.init len (fun i -> !@(data_char +@ i))

  let of_llb_data_ptr p = of_llb_data !@p
end

module Tracing = struct
  let enable () = C.llb_enable_tracing ()
  let disable () = C.llb_disable_tracing ()
end

module Quality_of_service = struct
  type t = Default | User_initiated | Utility | Background | Unspecified

  let to_int = function
    | Default -> T.llb_quality_of_service_default
    | User_initiated -> T.llb_quality_of_service_user_initiated
    | Utility -> T.llb_quality_of_service_utility
    | Background -> T.llb_quality_of_service_background
    | Unspecified -> T.llb_quality_of_service_unspecified

  let of_int = function
    | 0 -> Default
    | 1 -> User_initiated
    | 2 -> Utility
    | 3 -> Background
    | 4 -> Unspecified
    | n -> failwith (Printf.sprintf "unknown quality of service: %d" n)

  let get () = of_int (C.llb_get_quality_of_service ())
  let set qos = C.llb_set_quality_of_service (to_int qos)
end

let coerce_fn fn_type f =
  coerce (Foreign.funptr fn_type) (static_funptr fn_type) f

module Engine = struct
  module Rule_status = struct
    type t = Scanning | Up_to_date | Complete

    let of_int = function
      | 0 -> Scanning
      | 1 -> Up_to_date
      | 2 -> Complete
      | n -> failwith (Printf.sprintf "unknown rule status: %d" n)
  end

  module Task_interface = struct
    type t = T.llb_task_interface structure

    let request_input t key input_id =
      let d, _buf = Data.to_llb_data key in
      C.llb_buildengine_task_needs_input t (addr d)
        (Uintptr.of_int input_id)

    let must_follow t key =
      let d, _buf = Data.to_llb_data key in
      C.llb_buildengine_task_must_follow t (addr d)

    let discovered_dependency t key =
      let d, _buf = Data.to_llb_data key in
      C.llb_buildengine_task_discovered_dependency t (addr d)

    let complete t value ~force_change =
      let d, _buf = Data.to_llb_data value in
      C.llb_buildengine_task_is_complete t (addr d) force_change
  end

  module Task = struct
    type delegate = {
      start : Task_interface.t -> unit;
      provide_value : Task_interface.t -> input_id:int -> Data.t -> unit;
      inputs_available : Task_interface.t -> unit;
    }

    let create ~prevent_gc delegate =
      let td = make T.llb_task_delegate in
      setf td T.llb_td_context null;
      let destroy_ctx =
        coerce_fn (ptr void @-> returning void) (fun _ -> ())
      in
      setf td T.llb_td_destroy_context destroy_ctx;
      let start_fn =
        coerce_fn
          (ptr void @-> ptr void @-> T.llb_task_interface @-> returning void)
          (fun _ctx _eng_ctx ti -> delegate.start ti)
      in
      setf td T.llb_td_start start_fn;
      let provide_fn =
        coerce_fn
          (ptr void @-> ptr void @-> T.llb_task_interface @-> uintptr_t
         @-> ptr T.llb_data @-> returning void)
          (fun _ctx _eng_ctx ti input_id value_ptr ->
            let value = Data.of_llb_data_ptr value_ptr in
            delegate.provide_value ti
              ~input_id:(Uintptr.to_int input_id)
              value)
      in
      setf td T.llb_td_provide_value provide_fn;
      let available_fn =
        coerce_fn
          (ptr void @-> ptr void @-> T.llb_task_interface @-> returning void)
          (fun _ctx _eng_ctx ti -> delegate.inputs_available ti)
      in
      setf td T.llb_td_inputs_available available_fn;
      prevent_gc :=
        Obj.repr destroy_ctx :: Obj.repr start_fn :: Obj.repr provide_fn
        :: Obj.repr available_fn :: !(prevent_gc);
      C.llb_task_create td
  end

  type delegate = {
    lookup_rule : Data.t -> Task.delegate;
    error : string -> unit;
    cycle_detected : Data.t list -> unit;
  }

  type t = {
    ptr : T.llb_buildengine structure ptr;
    prevent_gc : Obj.t list ref;
  }

  let create delegate =
    let prevent_gc = ref [] in
    let d = make T.llb_buildengine_delegate in
    setf d T.llb_bed_context null;
    let destroy_ctx =
      coerce_fn (ptr void @-> returning void) (fun _ -> ())
    in
    setf d T.llb_bed_destroy_context destroy_ctx;
    let lookup_fn =
      coerce_fn
        (ptr void @-> ptr T.llb_data @-> ptr T.llb_rule @-> returning void)
        (fun _ctx key_ptr rule_out ->
          let key = Data.of_llb_data_ptr key_ptr in
          let task_delegate = delegate.lookup_rule key in
          let task_ptr = Task.create ~prevent_gc task_delegate in
          let rule = !@rule_out in
          let key_data, _key_buf = Data.to_llb_data key in
          setf rule T.llb_rule_context null;
          setf rule T.llb_rule_key key_data;
          let create_task_fn =
            coerce_fn
              (ptr void @-> ptr void @-> returning (ptr T.llb_task))
              (fun _ctx _eng_ctx -> task_ptr)
          in
          setf rule T.llb_rule_create_task create_task_fn;
          let is_valid_fn =
            coerce_fn
              (ptr void @-> ptr void @-> ptr T.llb_rule @-> ptr T.llb_data
             @-> returning bool)
              (fun _ctx _eng_ctx _rule _result -> true)
          in
          setf rule T.llb_rule_is_result_valid is_valid_fn;
          let update_fn =
            coerce_fn
              (ptr void @-> ptr void @-> int @-> returning void)
              (fun _ctx _eng_ctx _kind -> ())
          in
          setf rule T.llb_rule_update_status update_fn;
          prevent_gc :=
            Obj.repr create_task_fn :: Obj.repr is_valid_fn
            :: Obj.repr update_fn :: !(prevent_gc);
          rule_out <-@ rule)
    in
    setf d T.llb_bed_lookup_rule lookup_fn;
    let error_fn =
      coerce_fn
        (ptr void @-> string @-> returning void)
        (fun _ctx msg -> delegate.error msg)
    in
    setf d T.llb_bed_error error_fn;
    let cycle_fn =
      coerce_fn
        (ptr void @-> ptr T.llb_data @-> uint64_t @-> returning void)
        (fun _ctx keys_ptr count ->
          let count = Unsigned.UInt64.to_int count in
          let keys =
            List.init count (fun i -> Data.of_llb_data_ptr (keys_ptr +@ i))
          in
          delegate.cycle_detected keys)
    in
    setf d T.llb_bed_cycle_detected cycle_fn;
    prevent_gc :=
      Obj.repr destroy_ctx :: Obj.repr lookup_fn :: Obj.repr error_fn
      :: Obj.repr cycle_fn :: !(prevent_gc);
    let ptr = C.llb_buildengine_create d in
    { ptr; prevent_gc }

  let attach_db t ~path ~schema_version =
    let path_data, _buf = Data.to_llb_data path in
    let error_out = allocate (ptr char) (from_voidp char null) in
    let ok =
      C.llb_buildengine_attach_db t.ptr (addr path_data)
        (Unsigned.UInt32.of_int schema_version)
        error_out
    in
    if ok then Ok ()
    else
      let err_ptr = !@error_out in
      if is_null err_ptr then Error "unknown error"
      else
        let msg = coerce (ptr char) string err_ptr in
        Error msg

  let build t key =
    let key_data, _key_buf = Data.to_llb_data key in
    let result = make T.llb_data in
    C.llb_buildengine_build t.ptr (addr key_data) (addr result);
    Data.of_llb_data result

  let destroy t = C.llb_buildengine_destroy t.ptr
end

module Diagnostic_kind = struct
  type t = Note | Warning | Error

  let of_int = function
    | 0 -> Note
    | 1 -> Warning
    | 2 -> Error
    | n -> failwith (Printf.sprintf "unknown diagnostic kind: %d" n)

  let to_int = function
    | Note -> T.llb_buildsystem_diagnostic_kind_note
    | Warning -> T.llb_buildsystem_diagnostic_kind_warning
    | Error -> T.llb_buildsystem_diagnostic_kind_error

  let name t = C.llb_buildsystem_diagnostic_kind_get_name (to_int t)
end

module Command_result = struct
  type t = Succeeded | Failed | Cancelled | Skipped

  let of_int = function
    | 0 -> Succeeded
    | 1 -> Failed
    | 2 -> Cancelled
    | 3 -> Skipped
    | n -> failwith (Printf.sprintf "unknown command result: %d" n)
end

module Scheduler_algorithm = struct
  type t = Command_name_priority | Fifo

  let to_int = function
    | Command_name_priority ->
        T.llb_scheduler_algorithm_command_name_priority
    | Fifo -> T.llb_scheduler_algorithm_fifo
end

module Build_key = struct
  type t = T.llb_build_key structure ptr

  type kind =
    | Command
    | Custom_task
    | Directory_contents
    | Directory_tree_signature
    | Node
    | Target
    | Unknown
    | Directory_tree_structure_signature
    | Filtered_directory_contents
    | Stat

  let kind_of_int = function
    | 0 -> Command
    | 1 -> Custom_task
    | 2 -> Directory_contents
    | 3 -> Directory_tree_signature
    | 4 -> Node
    | 5 -> Target
    | 6 -> Unknown
    | 7 -> Directory_tree_structure_signature
    | 8 -> Filtered_directory_contents
    | 10 -> Stat
    | n -> failwith (Printf.sprintf "unknown build key kind: %d" n)

  let make data =
    let d, _buf = Data.to_llb_data data in
    C.llb_build_key_make (addr d)

  let destroy = C.llb_build_key_destroy
  let equal a b = C.llb_build_key_equal a b

  let hash k =
    Unsigned.Size_t.to_int (C.llb_build_key_hash k)

  let get_kind k = kind_of_int (C.llb_build_key_get_kind k)

  let make_command name = C.llb_build_key_make_command name

  let get_command_name k =
    let out = Ctypes.make T.llb_data in
    C.llb_build_key_get_command_name k (addr out);
    Data.of_llb_data out

  let make_custom_task ~name ~task_data =
    C.llb_build_key_make_custom_task name task_data

  let get_custom_task_name k =
    let out = Ctypes.make T.llb_data in
    C.llb_build_key_get_custom_task_name k (addr out);
    Data.of_llb_data out

  let get_custom_task_data k =
    let out = Ctypes.make T.llb_data in
    C.llb_build_key_get_custom_task_data k (addr out);
    Data.of_llb_data out

  let make_directory_contents path =
    C.llb_build_key_make_directory_contents path

  let get_directory_path k =
    let out = Ctypes.make T.llb_data in
    C.llb_build_key_get_directory_path k (addr out);
    Data.of_llb_data out

  let make_node path = C.llb_build_key_make_node path

  let get_node_path k =
    let out = Ctypes.make T.llb_data in
    C.llb_build_key_get_node_path k (addr out);
    Data.of_llb_data out

  let make_stat path = C.llb_build_key_make_stat path

  let get_stat_path k =
    let out = Ctypes.make T.llb_data in
    C.llb_build_key_get_stat_path k (addr out);
    Data.of_llb_data out

  let make_target name = C.llb_build_key_make_target name

  let get_target_name k =
    let out = Ctypes.make T.llb_data in
    C.llb_build_key_get_target_name k (addr out);
    Data.of_llb_data out
end

module Build_value = struct
  type t = T.llb_build_value structure ptr

  type kind =
    | Invalid
    | Virtual_input
    | Existing_input
    | Missing_input
    | Directory_contents
    | Directory_tree_signature
    | Directory_tree_structure_signature
    | Stale_file_removal
    | Missing_output
    | Failed_input
    | Successful_command
    | Failed_command
    | Propagated_failure_command
    | Cancelled_command
    | Skipped_command
    | Target
    | Filtered_directory_contents
    | Successful_command_with_output_signature

  let kind_of_int = function
    | 0 -> Invalid
    | 1 -> Virtual_input
    | 2 -> Existing_input
    | 3 -> Missing_input
    | 4 -> Directory_contents
    | 5 -> Directory_tree_signature
    | 6 -> Directory_tree_structure_signature
    | 7 -> Stale_file_removal
    | 8 -> Missing_output
    | 9 -> Failed_input
    | 10 -> Successful_command
    | 11 -> Failed_command
    | 12 -> Propagated_failure_command
    | 13 -> Cancelled_command
    | 14 -> Skipped_command
    | 15 -> Target
    | 16 -> Filtered_directory_contents
    | 17 -> Successful_command_with_output_signature
    | n -> failwith (Printf.sprintf "unknown build value kind: %d" n)

  let make data =
    let d, _buf = Data.to_llb_data data in
    C.llb_build_value_make (addr d)

  let clone = C.llb_build_value_clone
  let get_kind v = kind_of_int (C.llb_build_value_get_kind v)
  let destroy = C.llb_build_value_destroy
  let make_invalid () = C.llb_build_value_make_invalid ()
  let make_virtual_input () = C.llb_build_value_make_virtual_input ()
  let make_missing_input () = C.llb_build_value_make_missing_input ()
  let make_missing_output () = C.llb_build_value_make_missing_output ()
  let make_failed_input () = C.llb_build_value_make_failed_input ()
  let make_failed_command () = C.llb_build_value_make_failed_command ()
  let make_target () = C.llb_build_value_make_target ()

  let make_propagated_failure_command () =
    C.llb_build_value_make_propagated_failure_command ()

  let make_cancelled_command () =
    C.llb_build_value_make_cancelled_command ()

  let make_skipped_command () = C.llb_build_value_make_skipped_command ()

  let make_directory_tree_signature sig_ =
    C.llb_build_value_make_directory_tree_signature
      (Unsigned.UInt64.of_int sig_)

  let get_directory_tree_signature v =
    Unsigned.UInt64.to_int (C.llb_build_value_get_directory_tree_signature v)

  let make_directory_tree_structure_signature sig_ =
    C.llb_build_value_make_directory_tree_structure_signature
      (Unsigned.UInt64.of_int sig_)

  let get_directory_tree_structure_signature v =
    Unsigned.UInt64.to_int
      (C.llb_build_value_get_directory_tree_structure_signature v)

  let get_output_signature v =
    Unsigned.UInt64.to_int (C.llb_build_value_get_output_signature v)
end

module Database = struct
  type t = T.llb_database structure ptr

  let open_ ~path ~schema_version =
    let error_out = make T.llb_data in
    let cpath = CArray.of_string path in
    let db =
      C.llb_database_open (CArray.start cpath)
        (Unsigned.UInt32.of_int schema_version)
        (addr error_out)
    in
    if is_null db then
      let msg = Data.of_llb_data error_out in
      Error msg
    else Ok db

  let destroy = C.llb_database_destroy

  let get_epoch t =
    let error_out = make T.llb_data in
    Unsigned.UInt64.to_int (C.llb_database_get_epoch t (addr error_out))
end
