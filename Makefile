#######################################################################
#
# IOCamlJS - build a javscript ocaml repl for the ipython notebook.
#
# There are 4 stages in the build
#
# 1. compile iocaml source files
#
#    The top level is compiled with dynlink, js_of_ocaml,
#    compiler-libs and camlp4
#
# 2. link a byte code program
#
#    Link together the top level.  At this stage we may add
#    in user packages and syntax extensions.
#
# 3. expunge some modules
#
#    Remove internal compiler modules
#
# 4. convert to javascript
#
#    js_of_ocaml converts to javascript
#
# The makefile can be called with 3 variables set
#
# 1. PACKAGES - a set of ocamlfind packages
# 2. SYNTAX - a set of ocamlfind syntax extensions
# 3. EXPUNGE - module names to remove
#
# Note that the syntax extensions are not run here, they are linked
# into the toplevel.  Unforuntately there is no easy way to find the
# module names these things define and they must be expunged from the
# top level (mainly because synyax extensions are generally not packaged
# with their .cmi files which, unusually, js_of_ocaml would need).
#
# For example, to add js_of_ocaml it's syntax extensions use
#
# make all PACKAGES="js_of_ocaml" \
# 		   SYNTAX="js_of_ocaml.syntax" \
#          EXPUNGE="Pa_js"
#
# Note; to specify more than one package separate with spaces
#
# Note; we rely on ocamlfind to give us corrent include directories
#       and archive names - I am not sure how robust that really is,
#       espectially for syntax extensions
#
#######################################################################



#######################################################################
# configuration

# js_of_ocaml 
JS_OF_OCAML_OPTS=-pretty -noinline
JS_FILES= \
	runtime.js \
	$(shell ocamlfind query js_of_ocaml)/weak.js \
	toplevel_runtime.js 

# Compiler libs
COMPILER_LIBS=ocamlcommon.cma ocamlbytecomp.cma ocamltoplevel.cma
COMPILER_LIBS_INC=$(shell ocamlfind query -i-format compiler-libs)

# Camlp4 libs
CAMLP4_LIBS=camlp4o.cma
CAMLP4_LIBS_INC=$(shell ocamlfind query -i-format camlp4)

# ocamlfind packages.
STD_PACKAGES=-package str,dynlink,js_of_ocaml,js_of_ocaml_compiler
ifneq ($(PACKAGES),)
USER_PACKAGES=$(foreach p,$(PACKAGES),-package $(p))
#USER_PACKAGES_INC=$(foreach p,$(PACKAGES),`ocamlfind query -i-format $(p)`)
USER_PACKAGES_INC=$(foreach p,$(PACKAGES),`ocamlfind query -i-format $(p) -r | awk '{ printf $$0 " "}'`)
endif

# syntax extensions
ifneq ($(SYNTAX),)
SYNTAX_LIB=$(foreach s,$(SYNTAX),`ocamlfind query -predicates syntax,toploop,preprocessor -a-format $(s)`)
SYNTAX_INC=$(foreach s,$(SYNTAX),`ocamlfind query -i-format $(s)`)
endif

# compiler modules to be expunged
# this was found by a modified expunge util which printed everything it
# got rid of in a run where it was keeping specific modules.
EXPUNGE_COMPILER=\
Annot Ast_mapper Asttypes Btype Bytegen Bytelibrarian Bytelink Bytepackager Bytesections \
Camlp4 Camlp4_config Camlp4.Debug Camlp4.ErrorHandler Camlp4_import Camlp4.OCamlInitSyntax \
Camlp4OCamlParser Camlp4OCamlParserParser Camlp4OCamlRevisedParser Camlp4OCamlRevisedParserParser \
Camlp4.Options Camlp4.PreCast Camlp4.Printers Camlp4.Printers.DumpCamlp4Ast \
Camlp4.Printers.DumpOCamlAst Camlp4.Printers.Null Camlp4.Printers.OCaml Camlp4.Printers.OCamlr \
Camlp4.Register Camlp4.Sig Camlp4.Struct Camlp4.Struct.AstFilters Camlp4.Struct.Camlp4Ast \
Camlp4.Struct.Camlp4Ast2OCamlAst Camlp4.Struct.CleanAst Camlp4.Struct.CommentFilter \
Camlp4.Struct.DynAst Camlp4.Struct.DynLoader Camlp4.Struct.EmptyError Camlp4.Struct.EmptyPrinter \
Camlp4.Struct.FreeVars Camlp4.Struct.Grammar Camlp4.Struct.Grammar.Delete \
Camlp4.Struct.Grammar.Dynamic Camlp4.Struct.Grammar.Entry Camlp4.Struct.Grammar.Failed \
Camlp4.Struct.Grammar.Find Camlp4.Struct.Grammar.Fold Camlp4.Struct.Grammar.Insert \
Camlp4.Struct.Grammar.Parser Camlp4.Struct.Grammar.Print Camlp4.Struct.Grammar.Search \
Camlp4.Struct.Grammar.Static Camlp4.Struct.Grammar.Structure Camlp4.Struct.Grammar.Tools \
Camlp4.Struct.Lexer Camlp4.Struct.Loc Camlp4.Struct.Quotation Camlp4.Struct.Token \
Ccomp Clflags Cmi_format Cmo_format Cmt_format Compenv Compile Compiler Compiler.Annot_lexer \
Compiler.Annot_parser Compiler.Code Compiler.Deadcode Compiler.Dgraph Compiler.Driver \
Compiler.Eval Compiler.Flow Compiler.Freevars Compiler.Generate Compiler.Inline Compiler.Instr \
Compiler.Javascript Compiler.Js_assign Compiler.Js_lexer Compiler.Js_output Compiler.Js_parser \
Compiler.Js_simpl Compiler.Js_token Compiler.Js_traverse Compiler.Linker Compiler.Option \
Compiler.Parse_bytecode Compiler.Parse_info Compiler.Parse_js Compiler.Phisimpl \
Compiler.Pretty_print Compiler.Primitive Compiler.Pure_fun Compiler.Reserved Compiler.Source_map \
Compiler.Specialize Compiler.Specialize_js Compiler.Subst Compiler.Tailcall Compiler.Util \
Compiler.VarPrinter Compiler.Vlq64 Compmisc Config Consistbl CSS Ctype Datarepr Dll \
Dynlink Dynlinkaux Dynlinkaux.Btype Dynlinkaux.Bytesections Dynlinkaux.Clflags \
Dynlinkaux.Cmi_format Dynlinkaux.Config Dynlinkaux.Consistbl Dynlinkaux.Datarepr \
Dynlinkaux.Dll Dynlinkaux.Env Dynlinkaux.Ident Dynlinkaux.Instruct Dynlinkaux.Lambda \
Dynlinkaux.Location Dynlinkaux.Longident Dynlinkaux.Meta Dynlinkaux.Misc Dynlinkaux.Opcodes \
Dynlinkaux.Path Dynlinkaux.Predef Dynlinkaux.Primitive Dynlinkaux.Runtimedef Dynlinkaux.Subst \
Dynlinkaux.Symtable Dynlinkaux.Tbl Dynlinkaux.Terminfo Dynlinkaux.Types Dynlinkaux.Warnings \
Emitcode Env Envaux Errors Findlib Findlib_config Fl_args Fl_meta Fl_metascanner Fl_metatoken \
Fl_package_base Fl_split Fl_topo Gc Genprintval Ident Includeclass Includecore Includemod \
Instruct Iocaml_main Keycode Lambda Lexer Location Longident Lwt_util Main_args \
Matching Meta Misc Mtype Opcodes Oprint Parmatch Parse Parser Parsetree Path Pparse \
Pprintast Predef Primitive Printast Printinstr Printlambda Printtyp Printtyped Runtimedef \
Simplif Std_exit Str Stypes Subst Switch Symtable Syntaxerr Sys Tbl Terminfo Top Topmain \
Trace Translclass Translcore Translmod Translobj Typeclass Typecore Typedecl Typedtree \
TypedtreeIter TypedtreeMap Typemod Typeopt Types Typetexp Warnings

#######################################################################
# main build targets
all: static/services/kernels/js/kernel.js

js_toplevel:
	make all \
		SYNTAX="js_of_ocaml.syntax lwt.syntax.options lwt.syntax" \
		EXPUNGE="Pa_js Pa_lwt_options Pa_lwt"

# ... neither of these work ...

# requires external pcre_ocaml_init
tyxml_toplevel:
	make clean all \
		PACKAGES="pcre netsys netstring tyxml" \
		SYNTAX="tyxml.syntax" \
		EXPUNGE="Pa_tyxml pa_tyxml.Basic_types pa_tyxml.Camllexer pa_tyxml.Xhtmlparser pa_tyxml.Xhtmlsyntax pa_tyxml.Xmllexer"

# Bigarray.create: unsupported layout
cow_toplevel:
	make clean all \
		PACKAGES="cow" \
		SYNTAX="type_conv dyntype.syntax cow.syntax" \
		EXPUNGE="pa_dyntype cow.Atom cow.Code cow.Css cow.Html cow.Json cow.Markdown cow.Xhtml cow.Xml \
		dyntype.Type dyntype.Value \
		pa_cow pa_cow.Pa_css pa_cow.Pa_css.Location pa_cow.Pa_css.Options pa_cow.Pa_css.Parser pa_cow.Pa_css.Printer \
		pa_cow.Pa_css.QLexer pa_cow.Pa_css.Qast pa_cow.Pa_css.Quotations \
		pa_cow.Pa_html pa_cow.Pa_html.Extension pa_cow.Pa_html.Options pa_cow.Pa_html.Quotation pa_cow.Pa_html.Xhtml \
		pa_cow.Pa_json pa_cow.Pa_json.Extension pa_cow.Pa_json.Json \
		pa_cow.Pa_xml pa_cow.Pa_xml.Extension pa_cow.Pa_xml.Location pa_cow.Pa_xml.Options pa_cow.Pa_xml.Parser \
		pa_cow.Pa_xml.Printer pa_cow.Pa_xml.Qast pa_cow.Pa_xml.Quotation pa_cow.Pa_xml.Xml pa_cow.Pp_cow \
		pa_dyntype.P4_helpers pa_dyntype.P4_type pa_dyntype.P4_value \
		pa_dyntype.Pa_type pa_dyntype.Pa_value \
		sexplib sexplib.Conv sexplib.Conv_error sexplib.Exn_magic sexplib.Lexer sexplib.Macro \
		sexplib.Parser sexplib.Parser_with_layout sexplib.Path sexplib.Pre_sexp sexplib.Sexp sexplib.Sexp_intf \
		sexplib.Sexp_with_layout sexplib.Src_pos sexplib.Std sexplib.Type sexplib.Type_with_layout \
		uri_IP \
		"

#######################################################################
# build

iocaml.cmi: iocaml.mli
	ocamlfind ocamlc -c iocaml.mli

iocaml.cmo: iocaml.ml iocaml.cmi
	ocamlfind ocamlc -c \
		-syntax camlp4o -package js_of_ocaml.syntax \
		$(STD_PACKAGES) \
		$(COMPILER_LIBS_INC) \
		iocaml.ml

iocaml_main.cmo: iocaml_main.ml iocaml.cmi
	ocamlfind ocamlc -c iocaml_main.ml

iocaml_full.byte: iocaml.cmo iocaml_main.cmo
	ocamlfind ocamlc -linkall -linkpkg -o $@ \
		$(STD_PACKAGES) \
		$(USER_PACKAGES) \
		$(COMPILER_LIBS_INC) $(COMPILER_LIBS) \
		$(CAMLP4_LIBS_INC) $(CAMLP4_LIBS) \
		$(SYNTAX_LIB) \
		iocaml.cmo iocaml_main.cmo

iocaml.byte: iocaml_full.byte 
	`ocamlc -where`/expunge iocaml_full.byte iocaml.byte -v \
		$(EXPUNGE_COMPILER) $(EXPUNGE)

iocaml.js: iocaml.byte $(JS_FILES)
	js_of_ocaml -toplevel -noruntime $(JS_OF_OCAML_OPTS) \
		`ocamlfind query -i-format js_of_ocaml` \
		`ocamlfind query -i-format lwt` \
		$(USER_PACKAGES_INC) \
		$(SYNTAX_INC) \
		-I . $(COMPILER_LIBS_INC) $(JS_FILES) iocaml.byte

# main target
static/services/kernels/js/kernel.js: kernel.js iocaml.js
	cat kernel.js iocaml.js > static/services/kernels/js/kernel.js


#######################################################################
# install

install:
	cp -r static `ipython locate profile iocamljs`

clean::
	- rm -f *.cm[io] iocaml_full.byte iocaml.byte iocaml.js 
	- rm -fr *~

# debugging silly makefile macros
say:
	echo $(USER_PACKAGES)
	echo $(USER_PACKAGES_INC)
	echo $(SYNTAX_LIB)
	echo $(SYNTAX_INC)

