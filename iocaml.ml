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

class type iocaml = object
    method name : js_string Js.t Js.prop
    method execute : (js_string Js.t -> js_string Js.t) Js.writeonly_prop
end

let iocaml : iocaml Js.t = 
    let _ = Js.Unsafe.eval_string "iocaml = {};" in (* is there a proper way to do this? *)
    Js.Unsafe.variable "iocaml"

let exec_buffer = Buffer.create 100 
let exec_ppf = Format.formatter_of_buffer exec_buffer

let execute s =
    let () = Buffer.clear exec_buffer in
    let lb = Lexing.from_string s in
    begin try
        while true do
            try
                let phr = !Toploop.parse_toplevel_phrase lb in
                ignore(Toploop.execute_phrase true exec_ppf phr)
            with End_of_file -> raise End_of_file
            | x -> Errors.report_error exec_ppf x; raise End_of_file
        done
    with End_of_file -> ()
    end;
    Format.pp_print_flush exec_ppf ();
    Buffer.contents exec_buffer

let _ = 
    Firebug.console##log (Js.string "js_of_iocaml");
    Toploop.initialize_toplevel_env ();
    Toploop.input_name := "";
    iocaml##name <- Js.string "js_of_Iocaml";
    iocaml##execute <- (fun s -> Js.string (execute (Js.to_string s)))

