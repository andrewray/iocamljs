#######################################################################
#
# IOCamlJS - build a javscript ocaml repl for the ipython notebook.
#
# Uses the jsoo_mktop tool from js_of_ocaml
#
#######################################################################



COMPILER_LIBS_INC=$(shell ocamlfind query -i-format compiler-libs)
STD_PACKAGES=-package str,dynlink,js_of_ocaml,js_of_ocaml.compiler,js_of_ocaml.toplevel

iocaml.cmi: iocaml.mli
	ocamlfind ocamlc -c iocaml.mli

exec.cmi: exec.mli
	ocamlfind ocamlc -c exec.mli

exec.cmo: exec.ml exec.cmi 
	ocamlfind ocamlc -c \
		-syntax camlp4o -package js_of_ocaml.syntax,optcomp \
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

min: exec.cmo iocaml.cmo iocaml_main.cmo
	jsoo_mktop \
		-verbose \
		-dont-export-unit gc \
		-export-unit iocaml \
		exec.cmo iocaml.cmo iocaml_main.cmo \
		-jsopt +weak.js -jsopt +toplevel.js \
		-jsopt -I -jsopt ./ \
		-o iocaml.byte
	cat *.cmis.js kernel.js iocaml.js > static/services/kernels/js/kernel.min.js

full: exec.cmo iocaml.cmo iocaml_main.cmo
	jsoo_mktop \
		-verbose \
		-dont-export-unit gc \
		-top-syntax lwt.syntax \
		-top-syntax js_of_ocaml.syntax \
		-export-package lwt \
		-export-package js_of_ocaml \
		-export-unit iocaml \
		exec.cmo iocaml.cmo iocaml_main.cmo \
		-jsopt +weak.js -jsopt +toplevel.js \
		-jsopt -I -jsopt ./ \
		-o iocaml.byte
	cat *.cmis.js kernel.js iocaml.js > static/services/kernels/js/kernel.full.js

tyxml: exec.cmo iocaml.cmo iocaml_main.cmo
	jsoo_mktop \
		-verbose \
		-dont-export-unit gc \
		-top-syntax tyxml.syntax \
		-top-syntax lwt.syntax \
		-top-syntax js_of_ocaml.syntax \
		-export-package tyxml \
		-export-package lwt \
		-export-package js_of_ocaml \
		-export-unit iocaml \
		-export-unit html5_sigs \
		-export-unit html5_types \
		-export-unit svg_sigs \
		-export-unit svg_types \
		exec.cmo iocaml.cmo iocaml_main.cmo \
		-jsopt +weak.js -jsopt +toplevel.js \
		-jsopt -I -jsopt ./ \
		-o iocaml.byte
	cat *.cmis.js kernel.js iocaml.js > static/services/kernels/js/kernel.tyxml.js

#######################################################################
# install (not needed anymore with iocamlserver)

install:
	rm -rf `opam config var share`/iocamljs-kernel
	mkdir -p `opam config var share`/iocamljs-kernel/profile
	cp -r static `opam config var share`/iocamljs-kernel/profile
	#-which ipython >/dev/null 2>&1 && cp -r static `ipython locate profile iocamljs`

clean::
	- rm -f *.cmis.js
	- rm -f *.cm[io] iocaml_full.byte iocaml.byte iocaml.js 
	- rm -fr *~

# debugging silly makefile macros
say:
	echo $(USER_PACKAGES)
	echo $(USER_PACKAGES_INC)
	echo $(SYNTAX_LIB)
	echo $(SYNTAX_INC)

