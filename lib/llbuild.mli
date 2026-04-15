val get_version : unit -> string
val get_api_version : unit -> int

module Data : sig
  type t = string

  val of_string : string -> t
  val to_string : t -> string
end

module Tracing : sig
  val enable : unit -> unit
  val disable : unit -> unit
end

module Quality_of_service : sig
  type t = Default | User_initiated | Utility | Background | Unspecified

  val get : unit -> t
  val set : t -> unit
end

module Engine : sig
  module Rule_status : sig
    type t = Scanning | Up_to_date | Complete
  end

  module Task_interface : sig
    type t

    val request_input : t -> Data.t -> int -> unit
    val must_follow : t -> Data.t -> unit
    val discovered_dependency : t -> Data.t -> unit
    val complete : t -> Data.t -> force_change:bool -> unit
  end

  module Task : sig
    type delegate = {
      start : Task_interface.t -> unit;
      provide_value : Task_interface.t -> input_id:int -> Data.t -> unit;
      inputs_available : Task_interface.t -> unit;
    }
  end

  type delegate = {
    lookup_rule : Data.t -> Task.delegate;
    error : string -> unit;
    cycle_detected : Data.t list -> unit;
  }

  type t

  val create : delegate -> t

  val attach_db :
    t -> path:string -> schema_version:int -> (unit, string) result

  val build : t -> Data.t -> Data.t
  val destroy : t -> unit
end

module Diagnostic_kind : sig
  type t = Note | Warning | Error

  val name : t -> string
end

module Command_result : sig
  type t = Succeeded | Failed | Cancelled | Skipped
end

module Scheduler_algorithm : sig
  type t = Command_name_priority | Fifo
end

module Build_key : sig
  type t

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

  val make : Data.t -> t
  val destroy : t -> unit
  val equal : t -> t -> bool
  val hash : t -> int
  val get_kind : t -> kind
  val make_command : string -> t
  val get_command_name : t -> Data.t
  val make_custom_task : name:string -> task_data:string -> t
  val get_custom_task_name : t -> Data.t
  val get_custom_task_data : t -> Data.t
  val make_directory_contents : string -> t
  val get_directory_path : t -> Data.t
  val make_node : string -> t
  val get_node_path : t -> Data.t
  val make_stat : string -> t
  val get_stat_path : t -> Data.t
  val make_target : string -> t
  val get_target_name : t -> Data.t
end

module Build_value : sig
  type t

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

  val make : Data.t -> t
  val clone : t -> t
  val get_kind : t -> kind
  val destroy : t -> unit
  val make_invalid : unit -> t
  val make_virtual_input : unit -> t
  val make_missing_input : unit -> t
  val make_missing_output : unit -> t
  val make_failed_input : unit -> t
  val make_failed_command : unit -> t
  val make_target : unit -> t
  val make_propagated_failure_command : unit -> t
  val make_cancelled_command : unit -> t
  val make_skipped_command : unit -> t
  val make_directory_tree_signature : int -> t
  val get_directory_tree_signature : t -> int
  val make_directory_tree_structure_signature : int -> t
  val get_directory_tree_structure_signature : t -> int
  val get_output_signature : t -> int
end

module Database : sig
  type t

  val open_ : path:string -> schema_version:int -> (t, string) result
  val destroy : t -> unit
  val get_epoch : t -> int
end
