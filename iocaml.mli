
val jsoo_debug_on : unit -> unit
val display : ?base64:bool -> string -> string -> unit
val send_clear : ?wait:bool -> ?stdout:bool -> ?stderr:bool -> ?other:bool -> unit -> unit
val load_from_server : string -> string option
val dir_load : string -> unit
val load_comp_unit : string -> Format.formatter -> in_channel -> string

val main : unit -> unit

