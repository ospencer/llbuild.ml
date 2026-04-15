let failures = ref 0
let tests_run = ref 0

let assert_equal ~name expected actual =
  incr tests_run;
  if expected <> actual then begin
    Printf.eprintf "FAIL: %s\n  expected: %s\n  actual:   %s\n" name expected
      actual;
    incr failures
  end
  else Printf.printf "PASS: %s\n" name

let assert_true ~name condition =
  incr tests_run;
  if not condition then begin
    Printf.eprintf "FAIL: %s\n" name;
    incr failures
  end
  else Printf.printf "PASS: %s\n" name

let test_version () =
  let version = Llbuild.get_version () in
  assert_true ~name:"get_version returns non-empty string"
    (String.length version > 0);
  assert_true ~name:"get_version contains 'llbuild'"
    (let re = Str.regexp_string "llbuild" in
     try
       ignore (Str.search_forward re version 0);
       true
     with Not_found -> false)

let test_api_version () =
  let api = Llbuild.get_api_version () in
  assert_true ~name:"get_api_version returns positive int" (api > 0)

let test_data () =
  let s = "hello world" in
  let d = Llbuild.Data.of_string s in
  assert_equal ~name:"Data.of_string -> to_string roundtrip" s
    (Llbuild.Data.to_string d);
  let empty = Llbuild.Data.of_string "" in
  assert_equal ~name:"Data roundtrip empty string" ""
    (Llbuild.Data.to_string empty);
  let binary = String.init 256 (fun i -> Char.chr i) in
  let d2 = Llbuild.Data.of_string binary in
  assert_equal ~name:"Data roundtrip binary content" binary
    (Llbuild.Data.to_string d2)

let test_quality_of_service () =
  let open Llbuild.Quality_of_service in
  let original = get () in
  set Default;
  assert_true ~name:"QOS set/get Default" (get () = Default);
  set User_initiated;
  assert_true ~name:"QOS set/get User_initiated" (get () = User_initiated);
  set Utility;
  assert_true ~name:"QOS set/get Utility" (get () = Utility);
  set Background;
  assert_true ~name:"QOS set/get Background" (get () = Background);
  set original

let test_tracing () =
  Llbuild.Tracing.enable ();
  assert_true ~name:"Tracing.enable does not crash" true;
  Llbuild.Tracing.disable ();
  assert_true ~name:"Tracing.disable does not crash" true

let test_diagnostic_kind () =
  let open Llbuild.Diagnostic_kind in
  assert_equal ~name:"Diagnostic_kind Note name" "note" (name Note);
  assert_equal ~name:"Diagnostic_kind Warning name" "warning" (name Warning);
  assert_equal ~name:"Diagnostic_kind Error name" "error" (name Error)

let test_build_key_command () =
  let open Llbuild.Build_key in
  let k = make_command "my-command" in
  assert_true ~name:"Build_key command kind" (get_kind k = Command);
  assert_equal ~name:"Build_key get_command_name" "my-command"
    (get_command_name k);
  destroy k

let test_build_key_custom_task () =
  let open Llbuild.Build_key in
  let k = make_custom_task ~name:"task-name" ~task_data:"task-data" in
  assert_true ~name:"Build_key custom_task kind" (get_kind k = Custom_task);
  assert_equal ~name:"Build_key get_custom_task_name" "task-name"
    (get_custom_task_name k);
  assert_equal ~name:"Build_key get_custom_task_data" "task-data"
    (get_custom_task_data k);
  destroy k

let test_build_key_directory_contents () =
  let open Llbuild.Build_key in
  let k = make_directory_contents "/some/path" in
  assert_true ~name:"Build_key directory_contents kind"
    (get_kind k = Directory_contents);
  assert_equal ~name:"Build_key get_directory_path" "/some/path"
    (get_directory_path k);
  destroy k

let test_build_key_node () =
  let open Llbuild.Build_key in
  let k = make_node "/some/file.txt" in
  assert_true ~name:"Build_key node kind" (get_kind k = Node);
  assert_equal ~name:"Build_key get_node_path" "/some/file.txt"
    (get_node_path k);
  destroy k

let test_build_key_stat () =
  let open Llbuild.Build_key in
  let k = make_stat "/stat/path" in
  assert_true ~name:"Build_key stat kind" (get_kind k = Stat);
  assert_equal ~name:"Build_key get_stat_path" "/stat/path" (get_stat_path k);
  destroy k

let test_build_key_target () =
  let open Llbuild.Build_key in
  let k = make_target "my-target" in
  assert_true ~name:"Build_key target kind" (get_kind k = Target);
  assert_equal ~name:"Build_key get_target_name" "my-target"
    (get_target_name k);
  destroy k

let test_build_key_equal () =
  let open Llbuild.Build_key in
  let k1 = make_command "cmd" in
  let k2 = make_command "cmd" in
  let k3 = make_command "other" in
  assert_true ~name:"Build_key equal same command" (equal k1 k2);
  assert_true ~name:"Build_key not equal different command"
    (not (equal k1 k3));
  destroy k1;
  destroy k2;
  destroy k3

let test_build_key_hash () =
  let open Llbuild.Build_key in
  let k1 = make_command "cmd" in
  let k2 = make_command "cmd" in
  assert_true ~name:"Build_key hash equal for equal keys"
    (hash k1 = hash k2);
  destroy k1;
  destroy k2

let test_build_key_make_roundtrip () =
  let open Llbuild.Build_key in
  let k1 = make_command "roundtrip-cmd" in
  let k2 = make_command "roundtrip-cmd" in
  assert_true ~name:"Build_key make roundtrip preserves equality"
    (equal k1 k2);
  destroy k1;
  destroy k2

let test_build_value_constructors () =
  let open Llbuild.Build_value in
  let test_ctor name ctor expected_kind =
    let v = ctor () in
    assert_true
      ~name:(Printf.sprintf "Build_value %s kind" name)
      (get_kind v = expected_kind);
    destroy v
  in
  test_ctor "invalid" make_invalid Invalid;
  test_ctor "virtual_input" make_virtual_input Virtual_input;
  test_ctor "missing_input" make_missing_input Missing_input;
  test_ctor "missing_output" make_missing_output Missing_output;
  test_ctor "failed_input" make_failed_input Failed_input;
  test_ctor "failed_command" make_failed_command Failed_command;
  test_ctor "target" make_target Target;
  test_ctor "propagated_failure_command" make_propagated_failure_command
    Propagated_failure_command;
  test_ctor "cancelled_command" make_cancelled_command Cancelled_command;
  test_ctor "skipped_command" make_skipped_command Skipped_command

let test_build_value_directory_tree_signature () =
  let open Llbuild.Build_value in
  let v = make_directory_tree_signature 42 in
  assert_true ~name:"Build_value directory_tree_signature kind"
    (get_kind v = Directory_tree_signature);
  assert_true ~name:"Build_value get_directory_tree_signature"
    (get_directory_tree_signature v = 42);
  destroy v

let test_build_value_directory_tree_structure_signature () =
  let open Llbuild.Build_value in
  let v = make_directory_tree_structure_signature 99 in
  assert_true ~name:"Build_value directory_tree_structure_signature kind"
    (get_kind v = Directory_tree_structure_signature);
  assert_true ~name:"Build_value get_directory_tree_structure_signature"
    (get_directory_tree_structure_signature v = 99);
  destroy v

let test_build_value_clone () =
  let open Llbuild.Build_value in
  let v = make_directory_tree_signature 7 in
  let v2 = clone v in
  assert_true ~name:"Build_value clone preserves kind"
    (get_kind v2 = Directory_tree_signature);
  assert_true ~name:"Build_value clone preserves signature"
    (get_directory_tree_signature v2 = 7);
  destroy v;
  destroy v2

let create_engine_db path =
  let open Llbuild in
  let engine =
    Engine.create
      {
        lookup_rule =
          (fun _key ->
            {
              start = (fun _ti -> ());
              provide_value = (fun _ti ~input_id:_ _value -> ());
              inputs_available =
                (fun ti ->
                  Engine.Task_interface.complete ti "" ~force_change:false);
            });
        error = (fun _msg -> ());
        cycle_detected = (fun _keys -> ());
      }
  in
  (match Engine.attach_db engine ~path ~schema_version:9 with
  | Ok () -> ()
  | Error _ -> ());
  let _ = Engine.build engine "init" in
  Engine.destroy engine

let test_database () =
  let tmp = Filename.temp_file "llbuild_test" ".db" in
  (try Sys.remove tmp with Sys_error _ -> ());
  create_engine_db tmp;
  let result = Llbuild.Database.open_ ~path:tmp ~schema_version:9 in
  (match result with
  | Ok db ->
    let epoch = Llbuild.Database.get_epoch db in
    assert_true ~name:"Database epoch is non-negative" (epoch >= 0);
    Llbuild.Database.destroy db
  | Error msg ->
    assert_true
      ~name:(Printf.sprintf "Database.open_ succeeded (got error: %s)" msg)
      false);
  (try Sys.remove tmp with Sys_error _ -> ())

let test_database_reopen_increments_epoch () =
  let tmp = Filename.temp_file "llbuild_test" ".db" in
  (try Sys.remove tmp with Sys_error _ -> ());
  create_engine_db tmp;
  let epoch1 =
    match Llbuild.Database.open_ ~path:tmp ~schema_version:9 with
    | Ok db ->
      let e = Llbuild.Database.get_epoch db in
      Llbuild.Database.destroy db;
      e
    | Error msg ->
      assert_true
        ~name:
          (Printf.sprintf
             "Database reopen: first open succeeded (got error: %s)" msg)
        false;
      -1
  in
  create_engine_db tmp;
  let epoch2 =
    match Llbuild.Database.open_ ~path:tmp ~schema_version:9 with
    | Ok db ->
      let e = Llbuild.Database.get_epoch db in
      Llbuild.Database.destroy db;
      e
    | Error msg ->
      assert_true
        ~name:
          (Printf.sprintf
             "Database reopen: second open succeeded (got error: %s)" msg)
        false;
      -1
  in
  assert_true ~name:"Database epoch increments on reopen" (epoch2 > epoch1);
  (try Sys.remove tmp with Sys_error _ -> ())

let test_engine_simple_build () =
  let open Llbuild in
  let engine =
    Engine.create
      {
        lookup_rule =
          (fun _key ->
            {
              start = (fun _ti -> ());
              provide_value = (fun _ti ~input_id:_ _value -> ());
              inputs_available =
                (fun ti ->
                  Engine.Task_interface.complete ti "result-for-A"
                    ~force_change:false);
            });
        error = (fun msg -> Printf.eprintf "engine error: %s\n" msg);
        cycle_detected = (fun _keys -> ());
      }
  in
  let result = Engine.build engine "A" in
  assert_equal ~name:"Engine simple build result" "result-for-A" result;
  Engine.destroy engine

let test_engine_with_db () =
  let open Llbuild in
  let tmp = Filename.temp_file "llbuild_engine_test" ".db" in
  (try Sys.remove tmp with Sys_error _ -> ());
  let engine =
    Engine.create
      {
        lookup_rule =
          (fun _key ->
            {
              start = (fun _ti -> ());
              provide_value = (fun _ti ~input_id:_ _value -> ());
              inputs_available =
                (fun ti ->
                  Engine.Task_interface.complete ti "db-result"
                    ~force_change:false);
            });
        error = (fun _msg -> ());
        cycle_detected = (fun _keys -> ());
      }
  in
  let db_result = Engine.attach_db engine ~path:tmp ~schema_version:9 in
  assert_true ~name:"Engine attach_db succeeds" (Result.is_ok db_result);
  let result = Engine.build engine "key" in
  assert_equal ~name:"Engine build with db" "db-result" result;
  Engine.destroy engine;
  (try Sys.remove tmp with Sys_error _ -> ())

let test_engine_dependency_chain () =
  let open Llbuild in
  let engine =
    Engine.create
      {
        lookup_rule =
          (fun key ->
            if key = "B" then
              {
                start = (fun _ti -> ());
                provide_value = (fun _ti ~input_id:_ _value -> ());
                inputs_available =
                  (fun ti ->
                    Engine.Task_interface.complete ti "value-B"
                      ~force_change:false);
              }
            else
              {
                start =
                  (fun ti -> Engine.Task_interface.request_input ti "B" 1);
                provide_value = (fun _ti ~input_id:_ _value -> ());
                inputs_available =
                  (fun ti ->
                    Engine.Task_interface.complete ti "value-A"
                      ~force_change:false);
              });
        error = (fun msg -> Printf.eprintf "engine error: %s\n" msg);
        cycle_detected = (fun _keys -> ());
      }
  in
  let result = Engine.build engine "A" in
  assert_equal ~name:"Engine dependency chain result" "value-A" result;
  Engine.destroy engine

let test_engine_provide_value () =
  let open Llbuild in
  let received_value = ref "" in
  let received_input_id = ref (-1) in
  let engine =
    Engine.create
      {
        lookup_rule =
          (fun key ->
            if key = "dep" then
              {
                start = (fun _ti -> ());
                provide_value = (fun _ti ~input_id:_ _value -> ());
                inputs_available =
                  (fun ti ->
                    Engine.Task_interface.complete ti "dep-value"
                      ~force_change:false);
              }
            else
              {
                start =
                  (fun ti ->
                    Engine.Task_interface.request_input ti "dep" 42);
                provide_value =
                  (fun _ti ~input_id value ->
                    received_value := value;
                    received_input_id := input_id);
                inputs_available =
                  (fun ti ->
                    Engine.Task_interface.complete ti "done"
                      ~force_change:false);
              });
        error = (fun _msg -> ());
        cycle_detected = (fun _keys -> ());
      }
  in
  let _ = Engine.build engine "main" in
  assert_equal ~name:"Engine provide_value receives dep value" "dep-value"
    !received_value;
  assert_true ~name:"Engine provide_value receives correct input_id"
    (!received_input_id = 42);
  Engine.destroy engine

let test_engine_error_callback () =
  let open Llbuild in
  let tmp = Filename.temp_file "llbuild_engine_err" ".db" in
  (try Sys.remove tmp with Sys_error _ -> ());
  let errors = ref [] in
  let engine =
    Engine.create
      {
        lookup_rule =
          (fun _key ->
            {
              start = (fun _ti -> ());
              provide_value = (fun _ti ~input_id:_ _value -> ());
              inputs_available =
                (fun ti ->
                  Engine.Task_interface.complete ti "ok" ~force_change:false);
            });
        error = (fun msg -> errors := msg :: !errors);
        cycle_detected = (fun _keys -> ());
      }
  in
  let bad_result =
    Engine.attach_db engine ~path:"/nonexistent/path/db.db" ~schema_version:9
  in
  assert_true ~name:"Engine attach_db with bad path fails"
    (Result.is_error bad_result);
  Engine.destroy engine;
  (try Sys.remove tmp with Sys_error _ -> ())

let () =
  test_version ();
  test_api_version ();
  test_data ();
  test_quality_of_service ();
  test_tracing ();
  test_diagnostic_kind ();
  test_build_key_command ();
  test_build_key_custom_task ();
  test_build_key_directory_contents ();
  test_build_key_node ();
  test_build_key_stat ();
  test_build_key_target ();
  test_build_key_equal ();
  test_build_key_hash ();
  test_build_key_make_roundtrip ();
  test_build_value_constructors ();
  test_build_value_directory_tree_signature ();
  test_build_value_directory_tree_structure_signature ();
  test_build_value_clone ();
  test_database ();
  test_database_reopen_increments_epoch ();
  test_engine_simple_build ();
  test_engine_with_db ();
  test_engine_dependency_chain ();
  test_engine_provide_value ();
  test_engine_error_callback ();
  Printf.printf "\n%d/%d tests passed\n" (!tests_run - !failures) !tests_run;
  if !failures > 0 then begin
    Printf.eprintf "%d FAILURES\n" !failures;
    exit 1
  end
