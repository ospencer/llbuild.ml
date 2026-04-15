open Ctypes
open Type_description

module Functions (F : Ctypes.FOREIGN) = struct
  open F

  (* === Top-level (llbuild.h) === *)

  let llb_get_full_version_string =
    foreign "llb_get_full_version_string" (void @-> returning string)

  let llb_get_api_version =
    foreign "llb_get_api_version" (void @-> returning int)

  (* === Data (core.h) === *)

  let llb_data_destroy =
    foreign "llb_data_destroy" (ptr llb_data @-> returning void)

  (* === Build Engine (core.h) === *)

  let llb_buildengine_create =
    foreign "llb_buildengine_create"
      (llb_buildengine_delegate @-> returning (ptr llb_buildengine))

  let llb_buildengine_destroy =
    foreign "llb_buildengine_destroy" (ptr llb_buildengine @-> returning void)

  let llb_buildengine_attach_db =
    foreign "llb_buildengine_attach_db"
      (ptr llb_buildengine @-> ptr llb_data @-> uint32_t
      @-> ptr (ptr char)
      @-> returning bool)

  let llb_buildengine_build =
    foreign "llb_buildengine_build"
      (ptr llb_buildengine @-> ptr llb_data @-> ptr llb_data @-> returning void)

  let llb_buildengine_task_needs_input =
    foreign "llb_buildengine_task_needs_input"
      (llb_task_interface @-> ptr llb_data @-> uintptr_t @-> returning void)

  let llb_buildengine_task_must_follow =
    foreign "llb_buildengine_task_must_follow"
      (llb_task_interface @-> ptr llb_data @-> returning void)

  let llb_buildengine_task_discovered_dependency =
    foreign "llb_buildengine_task_discovered_dependency"
      (llb_task_interface @-> ptr llb_data @-> returning void)

  let llb_buildengine_task_is_complete =
    foreign "llb_buildengine_task_is_complete"
      (llb_task_interface @-> ptr llb_data @-> bool @-> returning void)

  let llb_task_create =
    foreign "llb_task_create" (llb_task_delegate @-> returning (ptr llb_task))

  let llb_enable_tracing = foreign "llb_enable_tracing" (void @-> returning void)

  let llb_disable_tracing =
    foreign "llb_disable_tracing" (void @-> returning void)

  (* === Build System (buildsystem.h) === *)

  let llb_buildsystem_diagnostic_kind_get_name =
    foreign "llb_buildsystem_diagnostic_kind_get_name" (int @-> returning string)

  let llb_buildsystem_create =
    foreign "llb_buildsystem_create"
      (llb_buildsystem_delegate @-> llb_buildsystem_invocation
      @-> returning (ptr llb_buildsystem))

  let llb_buildsystem_destroy =
    foreign "llb_buildsystem_destroy" (ptr llb_buildsystem @-> returning void)

  let llb_buildsystem_initialize =
    foreign "llb_buildsystem_initialize" (ptr llb_buildsystem @-> returning bool)

  let llb_buildsystem_build =
    foreign "llb_buildsystem_build"
      (ptr llb_buildsystem @-> ptr llb_data @-> returning bool)

  let llb_buildsystem_build_node =
    foreign "llb_buildsystem_build_node"
      (ptr llb_buildsystem @-> ptr llb_data @-> returning bool)

  let llb_buildsystem_cancel =
    foreign "llb_buildsystem_cancel" (ptr llb_buildsystem @-> returning void)

  let llb_buildsystem_tool_create =
    foreign "llb_buildsystem_tool_create"
      (ptr llb_data @-> llb_buildsystem_tool_delegate
      @-> returning (ptr llb_buildsystem_tool))

  let llb_buildsystem_external_command_create =
    foreign "llb_buildsystem_external_command_create"
      (ptr llb_data @-> llb_buildsystem_external_command_delegate
      @-> returning (ptr llb_buildsystem_command))

  let llb_buildsystem_command_get_name =
    foreign "llb_buildsystem_command_get_name"
      (ptr llb_buildsystem_command @-> ptr llb_data @-> returning void)

  let llb_buildsystem_command_should_show_status =
    foreign "llb_buildsystem_command_should_show_status"
      (ptr llb_buildsystem_command @-> returning bool)

  let llb_buildsystem_command_get_description =
    foreign "llb_buildsystem_command_get_description"
      (ptr llb_buildsystem_command @-> returning (ptr char))

  let llb_buildsystem_command_get_verbose_description =
    foreign "llb_buildsystem_command_get_verbose_description"
      (ptr llb_buildsystem_command @-> returning (ptr char))

  let llb_buildsystem_command_interface_task_needs_input =
    foreign "llb_buildsystem_command_interface_task_needs_input"
      (llb_task_interface @-> ptr llb_build_key @-> uintptr_t @-> returning void)

  let llb_buildsystem_command_interface_task_needs_single_use_input =
    foreign "llb_buildsystem_command_interface_task_needs_single_use_input"
      (llb_task_interface @-> ptr llb_build_key @-> uintptr_t @-> returning void)

  let llb_buildsystem_command_interface_task_discovered_dependency =
    foreign "llb_buildsystem_command_interface_task_discovered_dependency"
      (llb_task_interface @-> ptr llb_build_key @-> returning void)

  let llb_buildsystem_command_interface_get_file_info =
    foreign "llb_buildsystem_command_interface_get_file_info"
      (ptr llb_buildsystem_interface
      @-> string
      @-> returning llb_build_value_file_info)

  let llb_get_quality_of_service =
    foreign "llb_get_quality_of_service" (void @-> returning int)

  let llb_set_quality_of_service =
    foreign "llb_set_quality_of_service" (int @-> returning void)

  let llb_alloc = foreign "llb_alloc" (size_t @-> returning (ptr void))
  let llb_free = foreign "llb_free" (ptr void @-> returning void)

  (* === Database (db.h) === *)

  let llb_database_open =
    foreign "llb_database_open"
      (ptr char @-> uint32_t @-> ptr llb_data @-> returning (ptr llb_database))

  let llb_database_destroy =
    foreign "llb_database_destroy" (ptr llb_database @-> returning void)

  let llb_database_lookup_rule_result =
    foreign "llb_database_lookup_rule_result"
      (ptr llb_database @-> ptr llb_build_key @-> ptr llb_database_result
     @-> ptr llb_data @-> returning bool)

  let llb_database_destroy_result =
    foreign "llb_database_destroy_result"
      (ptr llb_database_result @-> returning void)

  let llb_database_fetch_result_get_count =
    foreign "llb_database_fetch_result_get_count"
      (ptr llb_database_fetch_result @-> returning uint64_t)

  let llb_database_fetch_result_get_key_at_index =
    foreign "llb_database_fetch_result_get_key_at_index"
      (ptr llb_database_fetch_result
      @-> int32_t
      @-> returning (ptr llb_build_key))

  let llb_database_fetch_result_contains_rule_results =
    foreign "llb_database_fetch_result_contains_rule_results"
      (ptr llb_database_fetch_result @-> returning bool)

  let llb_database_fetch_result_get_result_at_index =
    foreign "llb_database_fetch_result_get_result_at_index"
      (ptr llb_database_fetch_result
      @-> int32_t
      @-> returning (ptr llb_database_result))

  let llb_database_destroy_fetch_result =
    foreign "llb_database_destroy_fetch_result"
      (ptr llb_database_fetch_result @-> returning void)

  let llb_database_get_keys =
    foreign "llb_database_get_keys"
      (ptr llb_database
      @-> ptr (ptr llb_database_fetch_result)
      @-> ptr llb_data @-> returning bool)

  let llb_database_get_keys_and_results =
    foreign "llb_database_get_keys_and_results"
      (ptr llb_database
      @-> ptr (ptr llb_database_fetch_result)
      @-> ptr llb_data @-> returning bool)

  let llb_database_get_epoch =
    foreign "llb_database_get_epoch"
      (ptr llb_database @-> ptr llb_data @-> returning uint64_t)

  (* === Build Key (buildkey.h) === *)

  let llb_build_key_make =
    foreign "llb_build_key_make" (ptr llb_data @-> returning (ptr llb_build_key))

  let llb_build_key_destroy =
    foreign "llb_build_key_destroy" (ptr llb_build_key @-> returning void)

  let llb_build_key_equal =
    foreign "llb_build_key_equal"
      (ptr llb_build_key @-> ptr llb_build_key @-> returning bool)

  let llb_build_key_hash =
    foreign "llb_build_key_hash" (ptr llb_build_key @-> returning size_t)

  let llb_build_key_get_kind =
    foreign "llb_build_key_get_kind" (ptr llb_build_key @-> returning int)

  let llb_build_key_get_key_data =
    foreign "llb_build_key_get_key_data"
      (ptr llb_build_key @-> ptr void @-> ptr void @-> returning void)

  let llb_build_key_identifier_for_kind =
    foreign "llb_build_key_identifier_for_kind" (int @-> returning char)

  let llb_build_key_kind_for_identifier =
    foreign "llb_build_key_kind_for_identifier" (char @-> returning int)

  let llb_build_key_make_command =
    foreign "llb_build_key_make_command"
      (string @-> returning (ptr llb_build_key))

  let llb_build_key_get_command_name =
    foreign "llb_build_key_get_command_name"
      (ptr llb_build_key @-> ptr llb_data @-> returning void)

  let llb_build_key_make_custom_task =
    foreign "llb_build_key_make_custom_task"
      (string @-> string @-> returning (ptr llb_build_key))

  let llb_build_key_make_custom_task_with_data =
    foreign "llb_build_key_make_custom_task_with_data"
      (string @-> llb_data @-> returning (ptr llb_build_key))

  let llb_build_key_get_custom_task_name =
    foreign "llb_build_key_get_custom_task_name"
      (ptr llb_build_key @-> ptr llb_data @-> returning void)

  let llb_build_key_get_custom_task_data =
    foreign "llb_build_key_get_custom_task_data"
      (ptr llb_build_key @-> ptr llb_data @-> returning void)

  let llb_build_key_make_directory_contents =
    foreign "llb_build_key_make_directory_contents"
      (string @-> returning (ptr llb_build_key))

  let llb_build_key_get_directory_path =
    foreign "llb_build_key_get_directory_path"
      (ptr llb_build_key @-> ptr llb_data @-> returning void)

  let llb_build_key_make_node =
    foreign "llb_build_key_make_node" (string @-> returning (ptr llb_build_key))

  let llb_build_key_get_node_path =
    foreign "llb_build_key_get_node_path"
      (ptr llb_build_key @-> ptr llb_data @-> returning void)

  let llb_build_key_make_stat =
    foreign "llb_build_key_make_stat" (string @-> returning (ptr llb_build_key))

  let llb_build_key_get_stat_path =
    foreign "llb_build_key_get_stat_path"
      (ptr llb_build_key @-> ptr llb_data @-> returning void)

  let llb_build_key_make_target =
    foreign "llb_build_key_make_target"
      (string @-> returning (ptr llb_build_key))

  let llb_build_key_get_target_name =
    foreign "llb_build_key_get_target_name"
      (ptr llb_build_key @-> ptr llb_data @-> returning void)

  (* === Build Value (buildvalue.h) === *)

  let llb_build_value_make =
    foreign "llb_build_value_make"
      (ptr llb_data @-> returning (ptr llb_build_value))

  let llb_build_value_clone =
    foreign "llb_build_value_clone"
      (ptr llb_build_value @-> returning (ptr llb_build_value))

  let llb_build_value_get_kind =
    foreign "llb_build_value_get_kind" (ptr llb_build_value @-> returning int)

  let llb_build_value_destroy =
    foreign "llb_build_value_destroy" (ptr llb_build_value @-> returning void)

  let llb_build_value_make_invalid =
    foreign "llb_build_value_make_invalid"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_virtual_input =
    foreign "llb_build_value_make_virtual_input"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_existing_input =
    foreign "llb_build_value_make_existing_input"
      (llb_build_value_file_info @-> returning (ptr llb_build_value))

  let llb_build_value_get_output_info =
    foreign "llb_build_value_get_output_info"
      (ptr llb_build_value @-> returning llb_build_value_file_info)

  let llb_build_value_make_missing_input =
    foreign "llb_build_value_make_missing_input"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_missing_output =
    foreign "llb_build_value_make_missing_output"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_failed_input =
    foreign "llb_build_value_make_failed_input"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_successful_command =
    foreign "llb_build_value_make_successful_command"
      (ptr llb_build_value_file_info
      @-> int32_t
      @-> returning (ptr llb_build_value))

  let llb_build_value_make_failed_command =
    foreign "llb_build_value_make_failed_command"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_propagated_failure_command =
    foreign "llb_build_value_make_propagated_failure_command"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_cancelled_command =
    foreign "llb_build_value_make_cancelled_command"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_skipped_command =
    foreign "llb_build_value_make_skipped_command"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_target =
    foreign "llb_build_value_make_target"
      (void @-> returning (ptr llb_build_value))

  let llb_build_value_make_directory_tree_signature =
    foreign "llb_build_value_make_directory_tree_signature"
      (uint64_t @-> returning (ptr llb_build_value))

  let llb_build_value_get_directory_tree_signature =
    foreign "llb_build_value_get_directory_tree_signature"
      (ptr llb_build_value @-> returning uint64_t)

  let llb_build_value_make_directory_tree_structure_signature =
    foreign "llb_build_value_make_directory_tree_structure_signature"
      (uint64_t @-> returning (ptr llb_build_value))

  let llb_build_value_get_directory_tree_structure_signature =
    foreign "llb_build_value_get_directory_tree_structure_signature"
      (ptr llb_build_value @-> returning uint64_t)

  let llb_build_value_make_successful_command_with_output_signature =
    foreign "llb_build_value_make_successful_command_with_output_signature"
      (ptr llb_build_value_file_info
      @-> int32_t @-> uint64_t
      @-> returning (ptr llb_build_value))

  let llb_build_value_get_output_signature =
    foreign "llb_build_value_get_output_signature"
      (ptr llb_build_value @-> returning uint64_t)
end
