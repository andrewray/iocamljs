JSOO = /home/andyman/dev/tools/ocaml/js_of_ocaml-1.4

NAME=iocaml
OBJS=iocaml.cmo iocaml_main.cmo

all: $(NAME).js

include $(JSOO)/Makefile.conf
-include $(JSOO)/Makefile.local

ifeq ($(shell ocamlc -v | grep -q "version 4"; echo $$?),0)
OCAMLLIB=ocamlcommon.cma ocamlbytecomp.cma ocamltoplevel.cma
else
OCAMLLIB=toplevellib.cma
endif

COMP=$(JSOO)/compiler/$(COMPILER)
JSFILES= \
	runtime.js \
	$(JSOO)/runtime/weak.js \
	toplevel_runtime.js
OCAMLC=ocamlfind ocamlc -package lwt,str -pp "camlp4o $(JSOO)/lib/syntax/pa_js.cmo" -I +compiler-libs -I $(JSOO)/lib -I $(JSOO)/compiler
STDLIB= $(JSOO)/lib/$(LIBNAME).cma $(JSOO)/compiler/compiler.cma $(OCAMLLIB)
EXPUNGE=$(shell ocamlc -where)/expunge
# Removed gc and sys
STDLIB_MODULES=\
  arg \
  array \
  arrayLabels \
  buffer \
  callback \
  camlinternalLazy \
  camlinternalMod \
  camlinternalOO \
  char \
  complex \
  digest \
  filename \
  format \
  genlex \
  hashtbl \
  int32 \
  int64 \
  lazy \
  lexing \
  list \
  listLabels \
  map \
  marshal \
  moreLabels \
  nativeint \
  obj \
  oo \
  parsing \
  pervasives \
  printexc \
  printf \
  queue \
  random \
  scanf \
  set \
  sort \
  stack \
  stdLabels \
  stream \
  string \
  stringLabels \
  weak
PERVASIVES=$(STDLIB_MODULES) outcometree topdirs toploop

# Lwt and js_of_ocaml

EXTRA_MODULES = \
	css \
	dom \
	dom_events \
	dom_html \
	event_arrows \
	file \
	firebug \
	form \
	js \
	json \
	deriving_Json \
	lwt_js \
	lwt_js_events \
	regexp \
	url \
	xmlHttpRequest \
	lwt \
	typed_array \
	webGL \
	iocaml

EXTRA_INCLUDES = \
	-I . \
	`ocamlfind query js_of_ocaml -i-format` \
	`ocamlfind query lwt -i-format` \

#toplevel.byte: $(OBJS:cmx=cmo) toplevel.cmo
#	ocamlfind ocamlc -linkall -g -package str -linkpkg toplevellib.cma -o $@.tmp $^

$(NAME).js: $(NAME).byte $(COMP) $(JSFILES)
	$(COMP) -I $(shell ocamlc -where)/compiler-libs -toplevel -noinline -noruntime \
		$(EXTRA_INCLUDES) \
		$(JSFILES) $(NAME).byte $(OPTIONS)

$(NAME).byte: iocaml.cmi $(OBJS) $(JSOO)/compiler/compiler.cma
	$(OCAMLC) -linkall -package str,lwt -linkpkg -o $@.tmp $(STDLIB) $(OBJS)
	$(EXPUNGE) $@.tmp $@ $(PERVASIVES) $(EXTRA_MODULES)
	rm -f $@.tmp

%.cmo: %.ml
	$(OCAMLC) -c $<

%.cmi: $(JSOO)/compiler/compiler.cma

$(JSOO)/compiler/compiler.cma:
	$(MAKE) -C $(JSOO)/compiler compiler.cma

errors.cmi: errors.mli
	$(OCAMLC) -c $<

iocaml.cmi: iocaml.mli
	ocamlfind ocamlc -c -package js_of_ocaml iocaml.mli

clean::
	rm -f *.cm[io] $(NAME).byte $(NAME).js
	- rm -fr *~

# set up your profile first!
install:
	cat kernel.js iocaml.js > static/services/kernels/js/kernel.js
	cp -r static `ipython locate profile iocamljs`

# static dependancies guff
toplevel.cmo: errors.cmi $(JSOO)/compiler/driver.cmi 
iocaml_main.cmo: iocaml.cmi
iocaml.cmo: iocaml.cmi

