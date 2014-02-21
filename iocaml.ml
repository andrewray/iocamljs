(* Js_of_ocaml toplevel
 * http://www.ocsigen.org/js_of_ocaml/
 * Copyright (C) 2011 Jérôme Vouillon
 * Laboratoire PPS - CNRS Université Paris Diderot
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

open Js

let split_primitives p =
    let len = String.length p in
    let rec split beg cur =
        if cur >= len then []
        else if p.[cur] = '\000' then
            String.sub p beg (cur - beg) :: split (cur + 1) (cur + 1)
        else
            split beg (cur + 1) in
    Array.of_list(split 0 0)

class type global_data = object
    method toc : (string * string) list Js.readonly_prop
    method compile : (string -> string) Js.writeonly_prop
end

external global_data : unit -> global_data Js.t = "caml_get_global_data"
let g = global_data ()

let _ =
(*
  Util.set_debug "parser";
  Util.set_debug "deadcode";
  Util.set_debug "main";
*)
    let toc = g##toc in
    let prims = split_primitives (List.assoc "PRIM" toc) in

    (* so what does this actually do? *)
    let compile s =
        let output_program = Driver.from_string prims s in
        let b = Buffer.create 100 in
        output_program (Pretty_print.to_buffer b);
        Buffer.contents b
    in
    g##compile <- compile; (*XXX HACK!*)


class type iocaml_result = object
    method message : js_string t writeonly_prop
    method compilerStatus : bool t writeonly_prop
end

class type iocaml = object
    method name : js_string t prop
    method execute : (int -> js_string t -> iocaml_result t) writeonly_prop
end

let iocaml : iocaml Js.t = 
    let _ = Js.Unsafe.eval_string "iocaml = {};" in (* is there a proper way to do this? *)
    Js.Unsafe.variable "iocaml"

module Exec = struct

    let buffer = Buffer.create 4096
    let formatter = Format.formatter_of_buffer buffer

    let get_error_loc = function 
        | Syntaxerr.Error(x) -> Syntaxerr.location_of_error x
        | Lexer.Error(_, loc) 
        | Typecore.Error(loc, _, _) 
        | Typetexp.Error(loc, _, _) 
        | Typedecl.Error(loc, _) 
        | Typeclass.Error(loc, _, _) 
        | Typemod.Error(loc, _, _) 
        | Translcore.Error(loc, _) 
        | Translclass.Error(loc, _) 
        | Translmod.Error(loc, _) -> loc
        | _ -> raise Not_found

    exception Exit
    let report_error x = 
        try begin
            Errors.report_error formatter x; 
            (try begin
                if Location.highlight_locations formatter (get_error_loc x) Location.none then 
                    Format.pp_print_flush formatter ()
            end with _ -> ()); 
            false
        end with x -> (* shouldn't happen any more *) 
            (Format.fprintf formatter "exn: %s@." (Printexc.to_string x); false)

    let run_cell_lb execution_count lb =
        let cell_name = "["^string_of_int execution_count^"]" in
        Buffer.clear buffer;
        Location.init lb cell_name;
        Location.input_name := cell_name;
        Location.input_lexbuf := Some(lb);
        let success =
            try begin
                List.iter
                    (fun ph ->
                        if not (Toploop.execute_phrase true formatter ph) then raise Exit)
                    (!Toploop.parse_use_file lb);
                true
            end with
            | Exit -> false
            | Sys.Break -> (Format.fprintf formatter "Interrupted.@."; false)
            | x -> report_error x
        in
        success

    let run_cell execution_count code = run_cell_lb execution_count 
        (* little hack - make sure code ends with a '\n' otherwise the
         * error reporting isn't quite right *)
        Lexing.(from_string (code ^ "\n"))

    let execute execution_count str = 
        let status = run_cell execution_count (Js.to_string str) in
        let v : iocaml_result t = Js.Unsafe.obj [||] in
        v##message <- string (Buffer.contents buffer);
        v##compilerStatus <- bool status;
        v

end

let _ = 
    Firebug.console##log (Js.string "iocamljs");
    Sys.interactive := false;
    Toploop.set_paths();
    !Toploop.toplevel_startup_hook();
    Toploop.initialize_toplevel_env ();
    Toploop.input_name := "";
    iocaml##name <- Js.string "iocamljs"; (* XXX remove me, we've got the object now *)
    iocaml##execute <- Exec.execute



