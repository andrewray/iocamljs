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
open Compiler

module PatchCompile = struct

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

    let _ = (* patch the compile method *)
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

end

module Base64 = struct

(*
 * Copyright (c) 2006-2009 Citrix Systems Inc.
 * Copyright (c) 2010 Thomas Gazagnaire <thomas@gazagnaire.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)


    (* taken from https://github.com/avsm/ocaml-cohttp/blob/master/cohttp/base64.ml *)

    let code = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    let padding = '='

    let of_char x = if x = padding then 0 else String.index code x

    let to_char x = code.[x]

    let decode x = 
      let words = String.length x / 4 in
      let padding = 
        if String.length x = 0 then 0 else (
        if x.[String.length x - 2] = padding
        then 2 else (if x.[String.length x - 1] = padding then 1 else 0)) in
      let output = String.make (words * 3 - padding) '\000' in
      for i = 0 to words - 1 do
        let a = of_char x.[4 * i + 0]
        and b = of_char x.[4 * i + 1]
        and c = of_char x.[4 * i + 2]
        and d = of_char x.[4 * i + 3] in
        let n = (a lsl 18) lor (b lsl 12) lor (c lsl 6) lor d in
        let x = (n lsr 16) land 255
        and y = (n lsr 8) land 255
        and z = n land 255 in
        output.[3 * i + 0] <- char_of_int x;
        if i <> words - 1 || padding < 2 then output.[3 * i + 1] <- char_of_int y;
        if i <> words - 1 || padding < 1 then output.[3 * i + 2] <- char_of_int z;
      done;
      output

    let encode x = 
      let length = String.length x in
      let words = (length + 2) / 3 in (* rounded up *)
      let padding = if length mod 3 = 0 then 0 else 3 - (length mod 3) in
      let output = String.make (words * 4) '\000' in
      let get i = if i >= length then 0 else int_of_char x.[i] in
      for i = 0 to words - 1 do
        let x = get (3 * i + 0)
        and y = get (3 * i + 1)
        and z = get (3 * i + 2) in
        let n = (x lsl 16) lor (y lsl 8) lor z in 
        let a = (n lsr 18) land 63
        and b = (n lsr 12) land 63
        and c = (n lsr 6) land 63
        and d = n land 63 in
        output.[4 * i + 0] <- to_char a;
        output.[4 * i + 1] <- to_char b;
        output.[4 * i + 2] <- to_char c;
        output.[4 * i + 3] <- to_char d;
      done;
      for i = 1 to padding do
        output.[String.length output - i] <- '=';
      done;
      output

end

class type iocaml_result = object
    method message : js_string t writeonly_prop
    method compilerStatus : bool t writeonly_prop
end

class type iocaml = object
    method name : js_string t prop
    method execute : (int -> js_string t -> iocaml_result t) writeonly_prop
end

module Preprocessor = struct

    open Format

    module Ast2pt = Camlp4.Struct.Camlp4Ast2OCamlAst.Make(Camlp4.PreCast.Syntax.Ast)

    module CleanAst = Camlp4.Struct.CleanAst.Make(Camlp4.PreCast.Syntax.Ast)

    let print_warning = eprintf "%a:\n%s@." Camlp4.PreCast.Syntax.Loc.print

    let init_camlp4 = lazy (
      Camlp4.Register.iter_and_take_callbacks
        (fun (name, callback)-> callback ())
    )

    let implementation_file filename code =
      Lazy.force init_camlp4;
      let cs = Stream.of_string code in
      let loc = Camlp4.PreCast.Syntax.Loc.mk filename in
      Camlp4.PreCast.Syntax.current_warning := print_warning;
      let ast = 
        try 
          Camlp4.Register.CurrentParser.parse_implem loc cs
        with 
          Camlp4.PreCast.Syntax.Loc.Exc_located(loc, exc) -> 
            raise exc
        | x ->
            raise x
      in
      let ast = Camlp4.PreCast.AstFilters.fold_implem_filters (fun t filter -> filter t) ast in
      let ast = (new CleanAst.clean_ast)#str_item ast in
      let ast : Parsetree.structure = Obj.magic (Ast2pt.str_item ast) in
      Parsetree.Ptop_def(ast)

end

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

    let run_cell execution_count code = 
        run_cell_lb execution_count 
            (* little hack - make sure code ends with a '\n' otherwise the
             * error reporting isn't quite right *)
            Lexing.(from_string (code ^ "\n"))

    let run_cell_camlp4 execution_count code = 
        let cell_name = "["^string_of_int execution_count^"]" in
        Buffer.clear buffer;
        Location.input_name := cell_name;
        let success =
            try begin
                let ph = Preprocessor.implementation_file cell_name code in
                if not (Toploop.execute_phrase true formatter ph) then raise Exit;
                true
            end with
            | Exit -> false
            | Sys.Break -> (Format.fprintf formatter "Interrupted.@."; false)
            | x -> report_error x
        in
        success

    let execute execution_count str = 
        let status = run_cell_camlp4 execution_count (Js.to_string str) in
        let v : iocaml_result t = Js.Unsafe.obj [||] in
        v##message <- string (Buffer.contents buffer);
        v##compilerStatus <- bool status;
        v

end

let display ?(base64=false) mime_type data = 
    let data = 
        if not base64 then data
        else Base64.encode data
    in
    let data = Js.string data in
    Js.Unsafe.fun_call 
        (Js.Unsafe.variable "caml_ml_display") 
            [| Js.Unsafe.inject mime_type; Js.Unsafe.inject data  |]

let send_clear ?(wait=true) ?(stdout=true) ?(stderr=true) ?(other=true) () = 
   Js.Unsafe.fun_call 
        (Js.Unsafe.variable "caml_ml_clear_display") 
            [|
                Js.Unsafe.inject wait;
                Js.Unsafe.inject stdout;
                Js.Unsafe.inject stderr;
                Js.Unsafe.inject other;
            |]

let main () = 
    (* iocaml variable is now in kernel.js *)
    let iocaml : iocaml Js.t = Js.Unsafe.variable "iocaml" in
    Firebug.console##log (Js.string "iocamljs");
    Sys.interactive := false;
    Toploop.set_paths();
    !Toploop.toplevel_startup_hook();
    Toploop.initialize_toplevel_env ();
    Toploop.input_name := "";
    (* this is what kernel.js will used to compile code from the notebook *)
    iocaml##name <- Js.string "iocamljs"; (* XXX remove me, we've got the object now *)
    iocaml##execute <- Exec.execute;
    ()


