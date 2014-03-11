
val jsoo_debug : string list -> unit
val jsoo_debug_all : unit -> unit

val display : ?base64:bool -> string -> string -> unit
val send_clear : ?wait:bool -> ?stdout:bool -> ?stderr:bool -> ?other:bool -> unit -> unit
val load_from_server : string -> string option

val main : unit -> unit

