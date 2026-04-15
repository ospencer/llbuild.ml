open Ctypes

(* ===================================================================== *)
(* llb_data_t (core.h)                                                   *)
(* ===================================================================== *)

type llb_data

let llb_data : llb_data structure typ = structure "llb_data_t_"
let llb_data_length = field llb_data "length" uint64_t
let llb_data_data = field llb_data "data" (ptr uint8_t)
let () = seal llb_data

(* ===================================================================== *)
(* Opaque pointer types                                                  *)
(* ===================================================================== *)

type llb_buildengine

let llb_buildengine : llb_buildengine structure typ =
  structure "llb_buildengine_t_"

type llb_task

let llb_task : llb_task structure typ = structure "llb_task_t_"

type llb_buildsystem

let llb_buildsystem : llb_buildsystem structure typ =
  structure "llb_buildsystem_t_"

type llb_buildsystem_command

let llb_buildsystem_command : llb_buildsystem_command structure typ =
  structure "llb_buildsystem_command_t_"

type llb_buildsystem_tool

let llb_buildsystem_tool : llb_buildsystem_tool structure typ =
  structure "llb_buildsystem_tool_t_"

type llb_buildsystem_process

let llb_buildsystem_process : llb_buildsystem_process structure typ =
  structure "llb_buildsystem_process_t_"

type llb_buildsystem_interface

let llb_buildsystem_interface : llb_buildsystem_interface structure typ =
  structure "llb_buildsystem_interface_t_"

type llb_buildsystem_queue_job_context

let llb_buildsystem_queue_job_context :
    llb_buildsystem_queue_job_context structure typ =
  structure "llb_buildsystem_queue_job_context_t_"

type llb_database

let llb_database : llb_database structure typ = structure "llb_database_t_"

type llb_database_fetch_result

let llb_database_fetch_result : llb_database_fetch_result structure typ =
  structure "llb_database_result_keys_t_"

type llb_build_key

let llb_build_key : llb_build_key structure typ =
  structure "llb_build_key_t_"

type llb_build_value

let llb_build_value : llb_build_value structure typ =
  structure "llb_build_value_"

(* ===================================================================== *)
(* llb_task_interface_t (core.h)                                         *)
(* ===================================================================== *)

type llb_task_interface

let llb_task_interface : llb_task_interface structure typ =
  structure "llb_task_interface_t_"

let llb_task_interface_impl = field llb_task_interface "impl" (ptr void)
let llb_task_interface_ctx = field llb_task_interface "ctx" (ptr void)
let () = seal llb_task_interface

(* ===================================================================== *)
(* Enum constants (core.h)                                               *)
(* ===================================================================== *)

let llb_rule_is_scanning = 0
let llb_rule_is_up_to_date = 1
let llb_rule_is_complete = 2

(* ===================================================================== *)
(* llb_rule_t (core.h)                                                   *)
(* ===================================================================== *)

type llb_rule

let llb_rule : llb_rule structure typ = structure "llb_rule_t_"
let llb_rule_context = field llb_rule "context" (ptr void)
let llb_rule_key = field llb_rule "key" llb_data

let llb_rule_create_task =
  field llb_rule "create_task"
    (static_funptr (ptr void @-> ptr void @-> returning (ptr llb_task)))

let llb_rule_is_result_valid =
  field llb_rule "is_result_valid"
    (static_funptr
       (ptr void @-> ptr void @-> ptr llb_rule @-> ptr llb_data
      @-> returning bool))

let llb_rule_update_status =
  field llb_rule "update_status"
    (static_funptr (ptr void @-> ptr void @-> int @-> returning void))

let () = seal llb_rule

(* ===================================================================== *)
(* llb_buildengine_delegate_t (core.h)                                   *)
(* ===================================================================== *)

type llb_buildengine_delegate

let llb_buildengine_delegate : llb_buildengine_delegate structure typ =
  structure "llb_buildengine_delegate_t_"

let llb_bed_context = field llb_buildengine_delegate "context" (ptr void)

let llb_bed_destroy_context =
  field llb_buildengine_delegate "destroy_context"
    (static_funptr (ptr void @-> returning void))

let llb_bed_lookup_rule =
  field llb_buildengine_delegate "lookup_rule"
    (static_funptr
       (ptr void @-> ptr llb_data @-> ptr llb_rule @-> returning void))

let llb_bed_error =
  field llb_buildengine_delegate "error"
    (static_funptr (ptr void @-> string @-> returning void))

let llb_bed_cycle_detected =
  field llb_buildengine_delegate "cycle_detected"
    (static_funptr (ptr void @-> ptr llb_data @-> uint64_t @-> returning void))

let () = seal llb_buildengine_delegate

(* ===================================================================== *)
(* llb_task_delegate_t (core.h)                                          *)
(* ===================================================================== *)

type llb_task_delegate

let llb_task_delegate : llb_task_delegate structure typ =
  structure "llb_task_delegate_t_"

let llb_td_context = field llb_task_delegate "context" (ptr void)

let llb_td_destroy_context =
  field llb_task_delegate "destroy_context"
    (static_funptr (ptr void @-> returning void))

let llb_td_start =
  field llb_task_delegate "start"
    (static_funptr
       (ptr void @-> ptr void @-> llb_task_interface @-> returning void))

let llb_td_provide_value =
  field llb_task_delegate "provide_value"
    (static_funptr
       (ptr void @-> ptr void @-> llb_task_interface @-> uintptr_t
      @-> ptr llb_data @-> returning void))

let llb_td_inputs_available =
  field llb_task_delegate "inputs_available"
    (static_funptr
       (ptr void @-> ptr void @-> llb_task_interface @-> returning void))

let () = seal llb_task_delegate

(* ===================================================================== *)
(* Enum constants (buildsystem.h)                                        *)
(* ===================================================================== *)

let llb_buildsystem_diagnostic_kind_note = 0
let llb_buildsystem_diagnostic_kind_warning = 1
let llb_buildsystem_diagnostic_kind_error = 2

let llb_buildsystem_command_result_succeeded = 0
let llb_buildsystem_command_result_failed = 1
let llb_buildsystem_command_result_cancelled = 2
let llb_buildsystem_command_result_skipped = 3

let llb_buildsystem_discovered_dependency_kind_input = 0
let llb_buildsystem_discovered_dependency_kind_missing = 1
let llb_buildsystem_discovered_dependency_kind_output = 2

let llb_buildsystem_command_status_kind_is_scanning = 0
let llb_buildsystem_command_status_kind_is_up_to_date = 1
let llb_buildsystem_command_status_kind_is_complete = 2

let llb_cycle_action_force_build = 0
let llb_cycle_action_supply_prior_value = 1

let llb_scheduler_algorithm_command_name_priority = 0
let llb_scheduler_algorithm_fifo = 1

let llb_quality_of_service_default = 0
let llb_quality_of_service_user_initiated = 1
let llb_quality_of_service_utility = 2
let llb_quality_of_service_background = 3
let llb_quality_of_service_unspecified = 4

let llb_rule_run_reason_never_built = 0
let llb_rule_run_reason_signature_changed = 1
let llb_rule_run_reason_invalid_value = 2
let llb_rule_run_reason_input_rebuilt = 3
let llb_rule_run_reason_forced = 4

(* ===================================================================== *)
(* llb_fs_timestamp_t (buildsystem.h)                                    *)
(* ===================================================================== *)

type llb_fs_timestamp

let llb_fs_timestamp : llb_fs_timestamp structure typ =
  structure "llb_fs_timestamp_t_"

let llb_fs_timestamp_seconds = field llb_fs_timestamp "seconds" uint64_t
let llb_fs_timestamp_nanoseconds = field llb_fs_timestamp "nanoseconds" uint64_t
let () = seal llb_fs_timestamp

(* ===================================================================== *)
(* llb_fs_file_info_t (buildsystem.h)                                    *)
(* ===================================================================== *)

type llb_fs_file_info

let llb_fs_file_info : llb_fs_file_info structure typ =
  structure "llb_fs_file_info_t_"

let llb_fs_file_info_device = field llb_fs_file_info "device" uint64_t
let llb_fs_file_info_inode = field llb_fs_file_info "inode" uint64_t
let llb_fs_file_info_mode = field llb_fs_file_info "mode" uint64_t
let llb_fs_file_info_size = field llb_fs_file_info "size" uint64_t
let llb_fs_file_info_mod_time = field llb_fs_file_info "mod_time" llb_fs_timestamp
let () = seal llb_fs_file_info

(* ===================================================================== *)
(* llb_buildsystem_command_extended_result_t (buildsystem.h)             *)
(* We use nativeint for pid to handle both pid_t (Unix) and HANDLE (Win) *)
(* ===================================================================== *)

type llb_buildsystem_command_extended_result

let llb_buildsystem_command_extended_result :
    llb_buildsystem_command_extended_result structure typ =
  structure "llb_buildsystem_command_extended_result_t_"

let llb_bscer_result =
  field llb_buildsystem_command_extended_result "result" int

let llb_bscer_exit_status =
  field llb_buildsystem_command_extended_result "exit_status" int

let llb_bscer_utime =
  field llb_buildsystem_command_extended_result "utime" uint64_t

let llb_bscer_stime =
  field llb_buildsystem_command_extended_result "stime" uint64_t

let llb_bscer_maxrss =
  field llb_buildsystem_command_extended_result "maxrss" uint64_t

let llb_bscer_pid =
  field llb_buildsystem_command_extended_result "pid" nativeint

let () = seal llb_buildsystem_command_extended_result

(* ===================================================================== *)
(* llb_buildsystem_invocation_t (buildsystem.h)                          *)
(* ===================================================================== *)

type llb_buildsystem_invocation

let llb_buildsystem_invocation : llb_buildsystem_invocation structure typ =
  structure "llb_buildsystem_invocation_t_"

let llb_bsi_build_file_path =
  field llb_buildsystem_invocation "buildFilePath" string

let llb_bsi_db_path =
  field llb_buildsystem_invocation "dbPath" string

let llb_bsi_trace_file_path =
  field llb_buildsystem_invocation "traceFilePath" string

let llb_bsi_environment =
  field llb_buildsystem_invocation "environment" (ptr string)

let llb_bsi_show_verbose_status =
  field llb_buildsystem_invocation "showVerboseStatus" bool

let llb_bsi_use_serial_build =
  field llb_buildsystem_invocation "useSerialBuild" bool

let llb_bsi_scheduler_algorithm =
  field llb_buildsystem_invocation "schedulerAlgorithm" int

let llb_bsi_scheduler_lanes =
  field llb_buildsystem_invocation "schedulerLanes" uint32_t

let llb_bsi_qos =
  field llb_buildsystem_invocation "qos" int

let () = seal llb_buildsystem_invocation

(* ===================================================================== *)
(* llb_buildsystem_delegate_t (buildsystem.h)                            *)
(* ===================================================================== *)

type llb_buildsystem_delegate

let llb_buildsystem_delegate : llb_buildsystem_delegate structure typ =
  structure "llb_buildsystem_delegate_t_"

let llb_bsd_context =
  field llb_buildsystem_delegate "context" (ptr void)

let llb_bsd_fs_create_directory =
  field llb_buildsystem_delegate "fs_create_directory"
    (static_funptr (ptr void @-> string @-> returning bool))

let llb_bsd_fs_get_file_contents =
  field llb_buildsystem_delegate "fs_get_file_contents"
    (static_funptr (ptr void @-> string @-> ptr llb_data @-> returning bool))

let llb_bsd_fs_remove =
  field llb_buildsystem_delegate "fs_remove"
    (static_funptr (ptr void @-> string @-> returning bool))

let llb_bsd_fs_get_file_info =
  field llb_buildsystem_delegate "fs_get_file_info"
    (static_funptr
       (ptr void @-> string @-> ptr llb_fs_file_info @-> returning void))

let llb_bsd_fs_get_link_info =
  field llb_buildsystem_delegate "fs_get_link_info"
    (static_funptr
       (ptr void @-> string @-> ptr llb_fs_file_info @-> returning void))

let llb_bsd_fs_create_symlink =
  field llb_buildsystem_delegate "fs_create_symlink"
    (static_funptr (ptr void @-> string @-> string @-> returning bool))

let llb_bsd_lookup_tool =
  field llb_buildsystem_delegate "lookup_tool"
    (static_funptr
       (ptr void @-> ptr llb_data @-> returning (ptr llb_buildsystem_tool)))

let llb_bsd_handle_diagnostic =
  field llb_buildsystem_delegate "handle_diagnostic"
    (static_funptr
       (ptr void @-> int @-> string @-> int @-> int @-> string
      @-> returning void))

let llb_bsd_had_command_failure =
  field llb_buildsystem_delegate "had_command_failure"
    (static_funptr (ptr void @-> returning void))

let llb_bsd_command_status_changed =
  field llb_buildsystem_delegate "command_status_changed"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> int @-> returning void))

let llb_bsd_command_preparing =
  field llb_buildsystem_delegate "command_preparing"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> returning void))

let llb_bsd_should_command_start =
  field llb_buildsystem_delegate "should_command_start"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> returning bool))

let llb_bsd_command_started =
  field llb_buildsystem_delegate "command_started"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> returning void))

let llb_bsd_command_finished =
  field llb_buildsystem_delegate "command_finished"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> int @-> returning void))

let llb_bsd_command_found_discovered_dependency =
  field llb_buildsystem_delegate "command_found_discovered_dependency"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> string @-> int
      @-> returning void))

let llb_bsd_command_had_error =
  field llb_buildsystem_delegate "command_had_error"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> ptr llb_data
      @-> returning void))

let llb_bsd_command_had_note =
  field llb_buildsystem_delegate "command_had_note"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> ptr llb_data
      @-> returning void))

let llb_bsd_command_had_warning =
  field llb_buildsystem_delegate "command_had_warning"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> ptr llb_data
      @-> returning void))

let llb_bsd_command_cannot_build_output_due_to_missing_inputs =
  field llb_buildsystem_delegate
    "command_cannot_build_output_due_to_missing_inputs"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> ptr (ptr llb_build_key)
      @-> ptr (ptr llb_build_key) @-> uint64_t @-> returning void))

let llb_bsd_choose_command_from_multiple_producers =
  field llb_buildsystem_delegate "choose_command_from_multiple_producers"
    (static_funptr
       (ptr void @-> ptr (ptr llb_build_key)
      @-> ptr (ptr llb_buildsystem_command) @-> uint64_t
      @-> returning (ptr llb_buildsystem_command)))

let llb_bsd_cannot_build_node_due_to_multiple_producers =
  field llb_buildsystem_delegate
    "cannot_build_node_due_to_multiple_producers"
    (static_funptr
       (ptr void @-> ptr (ptr llb_build_key)
      @-> ptr (ptr llb_buildsystem_command) @-> uint64_t @-> returning void))

let llb_bsd_command_process_started =
  field llb_buildsystem_delegate "command_process_started"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command
      @-> ptr llb_buildsystem_process @-> returning void))

let llb_bsd_command_process_had_error =
  field llb_buildsystem_delegate "command_process_had_error"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command
      @-> ptr llb_buildsystem_process @-> ptr llb_data @-> returning void))

let llb_bsd_command_process_had_output =
  field llb_buildsystem_delegate "command_process_had_output"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command
      @-> ptr llb_buildsystem_process @-> ptr llb_data @-> returning void))

let llb_bsd_command_process_finished =
  field llb_buildsystem_delegate "command_process_finished"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command
      @-> ptr llb_buildsystem_process
      @-> ptr llb_buildsystem_command_extended_result @-> returning void))

let llb_bsd_determined_rule_needs_to_run =
  field llb_buildsystem_delegate "determined_rule_needs_to_run"
    (static_funptr
       (ptr void @-> ptr llb_build_key @-> int @-> ptr llb_build_key
      @-> returning void))

let llb_bsd_cycle_detected =
  field llb_buildsystem_delegate "cycle_detected"
    (static_funptr
       (ptr void @-> ptr (ptr llb_build_key) @-> uint64_t @-> returning void))

let llb_bsd_should_resolve_cycle =
  field llb_buildsystem_delegate "should_resolve_cycle"
    (static_funptr
       (ptr void @-> ptr (ptr llb_build_key) @-> uint64_t
      @-> ptr llb_build_key @-> int @-> returning uint8_t))

let () = seal llb_buildsystem_delegate

(* ===================================================================== *)
(* llb_buildsystem_tool_delegate_t (buildsystem.h)                       *)
(* ===================================================================== *)

type llb_buildsystem_tool_delegate

let llb_buildsystem_tool_delegate :
    llb_buildsystem_tool_delegate structure typ =
  structure "llb_buildsystem_tool_delegate_t_"

let llb_bstd_context =
  field llb_buildsystem_tool_delegate "context" (ptr void)

let llb_bstd_create_command =
  field llb_buildsystem_tool_delegate "create_command"
    (static_funptr
       (ptr void @-> ptr llb_data
      @-> returning (ptr llb_buildsystem_command)))

let llb_bstd_create_custom_command =
  field llb_buildsystem_tool_delegate "create_custom_command"
    (static_funptr
       (ptr void @-> ptr llb_build_key
      @-> returning (ptr llb_buildsystem_command)))

let llb_bstd_destroy_context =
  field llb_buildsystem_tool_delegate "destroy_context"
    (static_funptr (ptr void @-> returning void))

let () = seal llb_buildsystem_tool_delegate

(* ===================================================================== *)
(* llb_buildsystem_spawn_delegate_t (buildsystem.h)                      *)
(* ===================================================================== *)

type llb_buildsystem_spawn_delegate

let llb_buildsystem_spawn_delegate :
    llb_buildsystem_spawn_delegate structure typ =
  structure "llb_buildsystem_spawn_delegate_t_"

let llb_bsspd_context =
  field llb_buildsystem_spawn_delegate "context" (ptr void)

let llb_bsspd_process_started =
  field llb_buildsystem_spawn_delegate "process_started"
    (static_funptr (ptr void @-> nativeint @-> returning void))

let llb_bsspd_process_had_error =
  field llb_buildsystem_spawn_delegate "process_had_error"
    (static_funptr (ptr void @-> ptr llb_data @-> returning void))

let llb_bsspd_process_had_output =
  field llb_buildsystem_spawn_delegate "process_had_output"
    (static_funptr (ptr void @-> ptr llb_data @-> returning void))

let llb_bsspd_process_finished =
  field llb_buildsystem_spawn_delegate "process_finished"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command_extended_result
      @-> returning void))

let () = seal llb_buildsystem_spawn_delegate

(* ===================================================================== *)
(* llb_buildsystem_external_command_delegate_t (buildsystem.h)           *)
(* The `configure` callback has inner function pointer params — we       *)
(* represent those as ptr void since they're too complex for             *)
(* static_funptr nesting and are only used for specific advanced cases.  *)
(* ===================================================================== *)

type llb_buildsystem_external_command_delegate

let llb_buildsystem_external_command_delegate :
    llb_buildsystem_external_command_delegate structure typ =
  structure "llb_buildsystem_external_command_delegate_t_"

let llb_bsecd_context =
  field llb_buildsystem_external_command_delegate "context" (ptr void)

let llb_bsecd_configure =
  field llb_buildsystem_external_command_delegate "configure" (ptr void)

let llb_bsecd_get_signature =
  field llb_buildsystem_external_command_delegate "get_signature"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> ptr llb_data
      @-> returning void))

let llb_bsecd_start =
  field llb_buildsystem_external_command_delegate "start"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command
      @-> ptr llb_buildsystem_interface @-> llb_task_interface
      @-> returning void))

let llb_bsecd_provide_value =
  field llb_buildsystem_external_command_delegate "provide_value"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command
      @-> ptr llb_buildsystem_interface @-> llb_task_interface
      @-> ptr llb_build_value @-> uintptr_t @-> returning void))

let llb_bsecd_execute_command =
  field llb_buildsystem_external_command_delegate "execute_command"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command
      @-> ptr llb_buildsystem_interface @-> llb_task_interface
      @-> ptr llb_buildsystem_queue_job_context @-> returning int))

let llb_bsecd_execute_command_ex =
  field llb_buildsystem_external_command_delegate "execute_command_ex"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command
      @-> ptr llb_buildsystem_interface @-> llb_task_interface
      @-> ptr llb_buildsystem_queue_job_context
      @-> returning (ptr llb_build_value)))

let llb_bsecd_execute_command_detached =
  field llb_buildsystem_external_command_delegate "execute_command_detached"
    (ptr void)

let llb_bsecd_cancel_detached_command =
  field llb_buildsystem_external_command_delegate "cancel_detached_command"
    (ptr void)

let llb_bsecd_is_result_valid =
  field llb_buildsystem_external_command_delegate "is_result_valid"
    (static_funptr
       (ptr void @-> ptr llb_buildsystem_command @-> ptr llb_build_value
      @-> returning bool))

let llb_bsecd_is_result_valid_with_fallback =
  field llb_buildsystem_external_command_delegate
    "is_result_valid_with_fallback" (ptr void)

let llb_bsecd_destroy_context =
  field llb_buildsystem_external_command_delegate "destroy_context"
    (static_funptr (ptr void @-> returning void))

let () = seal llb_buildsystem_external_command_delegate

(* ===================================================================== *)
(* Enum constants (buildkey.h)                                           *)
(* ===================================================================== *)

let llb_build_key_kind_command = 0
let llb_build_key_kind_custom_task = 1
let llb_build_key_kind_directory_contents = 2
let llb_build_key_kind_directory_tree_signature = 3
let llb_build_key_kind_node = 4
let llb_build_key_kind_target = 5
let llb_build_key_kind_unknown = 6
let llb_build_key_kind_directory_tree_structure_signature = 7
let llb_build_key_kind_filtered_directory_contents = 8
let llb_build_key_kind_stat = 10

(* ===================================================================== *)
(* Enum constants (buildvalue.h)                                         *)
(* ===================================================================== *)

let llb_build_value_kind_invalid = 0
let llb_build_value_kind_virtual_input = 1
let llb_build_value_kind_existing_input = 2
let llb_build_value_kind_missing_input = 3
let llb_build_value_kind_directory_contents = 4
let llb_build_value_kind_directory_tree_signature = 5
let llb_build_value_kind_directory_tree_structure_signature = 6
let llb_build_value_kind_stale_file_removal = 7
let llb_build_value_kind_missing_output = 8
let llb_build_value_kind_failed_input = 9
let llb_build_value_kind_successful_command = 10
let llb_build_value_kind_failed_command = 11
let llb_build_value_kind_propagated_failure_command = 12
let llb_build_value_kind_cancelled_command = 13
let llb_build_value_kind_skipped_command = 14
let llb_build_value_kind_target = 15
let llb_build_value_kind_filtered_directory_contents = 16
let llb_build_value_kind_successful_command_with_output_signature = 17

(* ===================================================================== *)
(* llb_build_value_file_timestamp_t (buildvalue.h)                       *)
(* ===================================================================== *)

type llb_build_value_file_timestamp

let llb_build_value_file_timestamp :
    llb_build_value_file_timestamp structure typ =
  structure "llb_build_value_file_timestamp_t_"

let llb_bvft_seconds =
  field llb_build_value_file_timestamp "seconds" uint64_t

let llb_bvft_nanoseconds =
  field llb_build_value_file_timestamp "nanoseconds" uint64_t

let () = seal llb_build_value_file_timestamp

(* ===================================================================== *)
(* llb_build_value_file_info_t (buildvalue.h)                            *)
(* ===================================================================== *)

type llb_build_value_file_info

let llb_build_value_file_info : llb_build_value_file_info structure typ =
  structure "llb_build_value_file_info_t_"

let llb_bvfi_device = field llb_build_value_file_info "device" uint64_t
let llb_bvfi_inode = field llb_build_value_file_info "inode" uint64_t
let llb_bvfi_mode = field llb_build_value_file_info "mode" uint64_t
let llb_bvfi_size = field llb_build_value_file_info "size" uint64_t

let llb_bvfi_mod_time =
  field llb_build_value_file_info "modTime" llb_build_value_file_timestamp

let () = seal llb_build_value_file_info

(* ===================================================================== *)
(* llb_database_result_t (db.h)                                          *)
(* ===================================================================== *)

type llb_database_result

let llb_database_result : llb_database_result structure typ =
  structure "llb_database_result_t_"

let llb_dbr_value = field llb_database_result "value" llb_data
let llb_dbr_signature = field llb_database_result "signature" uint64_t
let llb_dbr_computed_at = field llb_database_result "computed_at" uint64_t
let llb_dbr_built_at = field llb_database_result "built_at" uint64_t
let llb_dbr_start = field llb_database_result "start" double
let llb_dbr_end_ = field llb_database_result "end" double

let llb_dbr_dependencies =
  field llb_database_result "dependencies" (ptr (ptr llb_build_key))

let llb_dbr_dependencies_count =
  field llb_database_result "dependencies_count" uint32_t

let () = seal llb_database_result
