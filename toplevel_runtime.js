// Js_of_ocaml toplevel runtime support
// http://www.ocsigen.org/js_of_ocaml/
// Copyright (C) 2011 Jérôme Vouillon
// Laboratoire PPS - CNRS Université Paris Diderot
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, with linking exception;
// either version 2.1 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

//Provides: caml_terminfo_setup
function caml_terminfo_setup () { return 1; } // Bad_term

//////////////////////////////////////////////////////////////////////

//Provides: caml_get_section_table
//Requires: caml_global_data
function caml_get_section_table () { return caml_global_data.toc; }

//Provides: caml_dynlink_get_current_libs
function caml_dynlink_get_current_libs () { return [0]; }

//Provides: caml_reify_bytecode
//Requires: caml_global_data
function caml_reify_bytecode (code, sz) {
  return eval(caml_global_data.compile(code).toString());
}

//Provides: caml_static_release_bytecode
function caml_static_release_bytecode () { return 0; }

//Provides: caml_static_alloc
//Requires: MlMakeString
function caml_static_alloc (len) { return new MlMakeString (len); }

//Provides: caml_static_free
function caml_static_free () { return 0; }

//Provides: caml_realloc_global
//Requires: caml_global_data
function caml_realloc_global (len) {
  if (len + 1 > caml_global_data.length) caml_global_data.length = len + 1;
  return 0;
}


/////////////////////////////////////////////////////////////////////////
// If we could get access to toplevel_runtime.js from the js_of_ocaml
// installation sensibly we could move the following functions to
// another file and link to the packaged version.  Unfortunately it
// doesn't seem to be installed at this point.

// missing?
function caml_ml_register_file(name,content) {
    joo_register_file(name,content)
}

// send mime_type display message
function caml_ml_display(mime_type, data) {
    IPython.notebook.kernel.send_mime(mime_type, data);
}

// clear display
function caml_ml_clear_display(wait,stdout,stderr,other) {
    IPython.notebook.kernel.send_clear(wait,stdout,stderr,other);
}

// print to stdout
function my_js_print_stdout(s) { 
    IPython.notebook.kernel.send_stdout_message(s.toString(), "stdout"); 
}

// print to stderr
function my_js_print_stderr(s) { 
    IPython.notebook.kernel.send_stdout_message(s.toString(), "stderr"); 
}

//Provides: caml_ml_pos_in
function caml_ml_pos_in(chan) {
    return chan.data.offset;
}

//Provides: caml_ml_pos_out
function caml_ml_pos_out(chan) {
    return chan.data.offset;
}

//Provides: caml_ml_seek_in
function caml_ml_seek_in(chan, pos) {
    chan.data.offset = pos;
}

//Provides: caml_ml_seek_out
function caml_ml_seek_out(chan, pos) {
    chan.data.offset = pos;
}

//Provides: caml_dynlink_add_primitive
//Requires: caml_failwith
function caml_dynlink_add_primitive() { caml_failwith("caml_dynlink_add_primitive"); }

//Provides: caml_dynlink_lookup_symbol
//Requires: caml_failwith
function caml_dynlink_lookup_symbol() { caml_failwith("caml_dynlink_lookup_symbol"); }

//Provides: caml_dynlink_open_lib
//Requires: caml_failwith
function caml_dynlink_open_lib() { caml_failwith("caml_dynlink_open_lib"); }

//Provides: caml_gc_full_major
//Requires: caml_failwith
function caml_gc_full_major() { caml_failwith("caml_gc_full_major"); }

//Provides: caml_get_current_environment
//Requires: caml_failwith
function caml_get_current_environment() { caml_failwith("caml_get_current_environment"); }

//Provides: caml_install_signal_handler
//Requires: caml_failwith
function caml_install_signal_handler() { caml_failwith("caml_install_signal_handler"); }

//Provides: caml_invoke_traced_function
//Requires: caml_failwith
function caml_invoke_traced_function() { caml_failwith("caml_invoke_traced_function"); }

//Provides: caml_md5_chan
//Requires: caml_failwith
function caml_md5_chan() { caml_failwith("caml_md5_chan"); }

//Provides: caml_ml_input_int
//Requires: caml_ml_input_char, caml_failwith
function caml_ml_input_int(chan) {
    var a, b, c, d;
    d = caml_ml_input_char(chan);
    c = caml_ml_input_char(chan);
    b = caml_ml_input_char(chan);
    a = caml_ml_input_char(chan);
    return a + (b << 8) + (c << 16) + (d << 24);
}

//Provides: caml_ml_output_int
//Requires: caml_failwith
function caml_ml_output_int() { caml_failwith("caml_ml_output_int"); }

//Provides: caml_ml_pos_in_64
//Requires: caml_failwith
function caml_ml_pos_in_64() { caml_failwith("caml_ml_pos_in_64"); }

//Provides: caml_ml_pos_out_64
//Requires: caml_failwith
function caml_ml_pos_out_64() { caml_failwith("caml_ml_pos_out_64"); }

//Provides: caml_ml_seek_in_64
//Requires: caml_failwith
function caml_ml_seek_in_64() { caml_failwith("caml_ml_seek_in_64"); }

//Provides: caml_ml_seek_out_64
//Requires: caml_failwith
function caml_ml_seek_out_64() { caml_failwith("caml_ml_seek_out_64"); }

//Provides: caml_ml_set_binary_mode
//Requires: caml_failwith
function caml_ml_set_binary_mode() { caml_failwith("caml_ml_set_binary_mode"); }

//Provides: caml_output_value
//Requires: caml_failwith
function caml_output_value(ch,v,fl) { 
    var t = caml_output_value_to_string(t);
    caml_ml_output(ch,t,0,t.getLen());
}

//Provides: caml_record_backtrace
//Requires: caml_failwith
function caml_record_backtrace() { caml_failwith("caml_record_backtrace"); }

//Provides: caml_sys_chdir
//Requires: caml_failwith
function caml_sys_chdir() { caml_failwith("caml_sys_chdir"); }

//Provides: caml_sys_getcwd
//Requires: caml_failwith
function caml_sys_getcwd() { caml_failwith("caml_sys_getcwd"); }

//Provides: caml_sys_read_directory
//Requires: caml_failwith
function caml_sys_read_directory() { caml_failwith("caml_sys_read_directory"); }

//Provides: caml_sys_system_command
//Requires: caml_failwith
function caml_sys_system_command() { caml_failwith("caml_sys_system_command"); }

//Provides: caml_terminfo_backup
//Requires: caml_failwith
function caml_terminfo_backup() { caml_failwith("caml_terminfo_backup"); }

//Provides: caml_terminfo_resume
//Requires: caml_failwith
function caml_terminfo_resume() { caml_failwith("caml_terminfo_resume"); }

//Provides: caml_terminfo_standout
//Requires: caml_failwith
function caml_terminfo_standout() { caml_failwith("caml_terminfo_standout"); }

