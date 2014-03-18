module Compile : sig
    (* enable generation of stubs for missing c primitives *)
    val generate_stubs : bool ref
    (* get missing c primitives *)
    val get_stubs : unit -> string array
    (* install timer for "times" debug option *)
    val set_timer : (unit -> float) -> unit
    (* set js_of_ocaml debugging option *)
    val jsoo_debug : string -> bool -> unit
end

(* for internal use only *)
val touch_me_up : unit -> unit

(* display mime data in notebook *)
val display : ?base64:bool -> string -> string -> unit

(* clear output panel *)
val send_clear : ?wait:bool -> ?stdout:bool -> ?stderr:bool -> ?other:bool -> unit -> unit

(* load a (binary) file from the server *)
val load_from_server : string -> string option

val output_cell_max_height : string ref

val main : unit -> unit

