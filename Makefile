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
# 3. expunge modules
#
#    Specify the (user) module to include and get rid of everything
#    else
#
# 4. convert to javascript
#
#    js_of_ocaml converts to javascript
#
# The makefile can be called with 3 variables set
#
# 1. PACKAGES - a set of ocamlfind packages
# 2. SYNTAX - a set of ocamlfind syntax extensions
# 3. MODULES - module names to keep
#
# Note; the syntax extensions in step 2 are linked in not run
# Note; to specify more than one package separate with spaces
# Note; we rely on ocamlfind to give us corrent include directories
#       and archive names - I am not sure how robust that really is
#
#######################################################################



#######################################################################
# configuration

# js_of_ocaml
ifeq ($(OPT),1)
JS_OF_OCAML_OPTS=-opt 2 noinline -linkall
else
JS_OF_OCAML_OPTS=-noinline -linkall
endif

JS_FILES= \
	runtime.js \
	$(shell ocamlfind query js_of_ocaml)/weak.js \
	toplevel_runtime.js 

# Compiler libs
COMPILER_LIBS=ocamlcommon.cma ocamlbytecomp.cma ocamltoplevel.cma
COMPILER_LIBS_INC=$(shell ocamlfind query -i-format compiler-libs)

# Camlp4 libs
ifeq ($(CAMLP4),1)
CAMLP4_LIBS=camlp4o.cma Camlp4Top.cmo
CAMLP4_LIBS_INC=$(shell ocamlfind query -i-format camlp4)
else
CAMLP4_LIBS=
CAMLP4_LIBS_INC=
endif

# ocamlfind packages.
STD_PACKAGES=-package str,dynlink,js_of_ocaml,js_of_ocaml_compiler
ifneq ($(PACKAGES),)
USER_PACKAGES=$(foreach p,$(PACKAGES),-package $(p))
USER_PACKAGES_INC=$(foreach p,$(PACKAGES),`ocamlfind query -i-format $(p) -r | awk '{ printf $$0 " "}'`)
endif

# syntax extensions
ifneq ($(SYNTAX),)
SYNTAX_LIB=$(foreach s,$(SYNTAX),`ocamlfind query -predicates syntax,toploop,preprocessor -a-format $(s)`)
SYNTAX_INC=$(foreach s,$(SYNTAX),`ocamlfind query -i-format $(s)`)
endif


KEEP_COMPILER=\
Arg Array ArrayLabels Buffer Callback CamlinternalLazy CamlinternalMod CamlinternalOO \
Char Complex Digest Dynlink Filename Format Genlex Gc Hashtbl Int32 Int64 Lazy Lexing \
List ListLabels Map Marshal MoreLabels Nativeint Obj Oo Parsing Pervasives Printexc \
Printf Queue Random Scanf Set Sort Stack StdLabels Stream String StringLabels Sys Weak \
Iocaml

# camlp4
ifeq ($(CAMLP4),1)
KEEP_CAMLP4=Camlp4 Camlp4_config Camlp4_import Camlp4Top
endif

# lwt
ifeq ($(LWT),1)
KEEP_LWT=\
Lwt Lwt_condition Lwt_list Lwt_mutex Lwt_mvar Lwt_pool \
Lwt_pqueue Lwt_sequence Lwt_stream Lwt_switch
LWT_INCLUDE=`ocamlfind query -i-format lwt`
endif

# js_of_ocaml
ifeq ($(JSOO),1)
KEEP_JSOO=\
CSS Dom Dom_events Dom_html Event_arrows File Firebug Form Js \
Json Lwt_js Lwt_js_events Regexp Sys_js Typed_array Url \
WebGL WebSockets XmlHttpRequest 
JSOO_INCLUDE=`ocamlfind query -i-format js_of_ocaml`
endif

KEEP_TOP=Outcometree Topdirs Toploop 

KEEP_MODULES=$(KEEP_COMPILER) $(KEEP_CAMLP4) $(KEEP_LWT) $(KEEP_JSOO) $(KEEP_TOP)

#######################################################################
# main build targets

EXT=

all: static/services/kernels/js/kernel$(EXT).js

full:
	make all \
		OPT=1 EXT=".full" \
		CAMLP4=1 LWT=1 JSOO=1 \
		SYNTAX="js_of_ocaml.syntax lwt.syntax.options lwt.syntax" 

min:
	make all OPT=1 EXT=".min"

#######################################################################
# build

iocaml.cmi: iocaml.mli
	ocamlfind ocamlc -c iocaml.mli

exec.cmi: exec.mli
	ocamlfind ocamlc -c exec.mli

exec.cmo: exec.ml exec.cmi 
	ocamlfind ocamlc -c \
		-syntax camlp4o -package js_of_ocaml.syntax \
		$(STD_PACKAGES) \
		$(COMPILER_LIBS_INC) \
		exec.ml

iocaml.cmo: iocaml.ml exec.cmi iocaml.cmi
	ocamlfind ocamlc -c \
		-syntax camlp4o -package js_of_ocaml.syntax \
		$(STD_PACKAGES) \
		$(COMPILER_LIBS_INC) \
		iocaml.ml

iocaml_main.cmo: iocaml_main.ml iocaml.cmi
	ocamlfind ocamlc -c iocaml_main.ml

iocaml_full.byte: exec.cmo iocaml.cmo iocaml_main.cmo
	ocamlfind ocamlc -linkall -linkpkg -o $@ \
		$(STD_PACKAGES) \
		$(USER_PACKAGES) \
		$(COMPILER_LIBS_INC) $(COMPILER_LIBS) \
		$(CAMLP4_LIBS_INC) $(CAMLP4_LIBS) \
		$(SYNTAX_LIB) \
		exec.cmo iocaml.cmo iocaml_main.cmo

iocaml.byte: iocaml_full.byte 
	`ocamlc -where`/expunge iocaml_full.byte iocaml.byte \
		$(KEEP_MODULES) $(MODULES)

iocaml.js: iocaml.byte $(JS_FILES)
	js_of_ocaml -toplevel -noruntime $(JS_OF_OCAML_OPTS) \
		$(USER_PACKAGES_INC) \
		$(SYNTAX_INC) $(CAMLP4_LIBS_INC) \
		-I . $(COMPILER_LIBS_INC) $(JS_FILES) \
		$(JSOO_INCLUDE) $(LWT_INCLUDE) \
		iocaml.byte

# main target
static/services/kernels/js/kernel$(EXT).js: kernel.js iocaml.js
	cat kernel.js iocaml.js > static/services/kernels/js/kernel$(EXT).js

#######################################################################
# install (not needed anymore with iocamlserver)

install:
	cp -r static `ipython locate profile iocamljs`
	cp -r static `opam config var share`/iocamljs-kernel/profile

clean::
	- rm -f *.cm[io] iocaml_full.byte iocaml.byte iocaml.js 
	- rm -fr *~

# debugging silly makefile macros
say:
	echo $(USER_PACKAGES)
	echo $(USER_PACKAGES_INC)
	echo $(SYNTAX_LIB)
	echo $(SYNTAX_INC)

