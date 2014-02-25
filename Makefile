NAME=iocaml
OBJS=iocaml.cmo iocaml_main.cmo

all: $(NAME).js

ifeq ($(shell ocamlc -v | grep -q "version 4"; echo $$?),0)
OCAMLLIB=ocamlcommon.cma ocamlbytecomp.cma ocamltoplevel.cma
else
OCAMLLIB=toplevellib.cma
endif

COMP=js_of_ocaml
JSFILES= \
	runtime.js \
	$(shell ocamlfind query js_of_ocaml)/weak.js \
	toplevel_runtime.js 
OCAMLC=ocamlfind ocamlc -package lwt,str -syntax camlp4o -package js_of_ocaml.syntax,compiler-libs,js_of_ocaml_compiler,js_of_ocaml
STDLIB=$(OCAMLLIB)
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

PREPROCESSORS = \
	`ocamlfind query js_of_ocaml -i-format` pa_js.cmo

#toplevel.byte: $(OBJS:cmx=cmo) toplevel.cmo
#	ocamlfind ocamlc -linkall -g -package str -linkpkg toplevellib.cma -o $@.tmp $^

$(NAME).js: $(NAME).byte $(JSFILES)
	$(COMP) -I $(shell ocamlc -where)/compiler-libs -toplevel -noinline -noruntime -pretty \
		$(EXTRA_INCLUDES) \
		$(JSFILES) $(NAME).byte $(OPTIONS)

$(NAME).byte: iocaml.cmi $(OBJS) 
	$(OCAMLC) -linkall -package str,lwt,dynlink -I +camlp4 -linkpkg -o $@.tmp $(STDLIB) \
		camlp4o.cma $(PREPROCESSORS) \
		$(OBJS)
	$(EXPUNGE) $@.tmp $@ $(PERVASIVES) $(EXTRA_MODULES)
	rm -f $@.tmp

%.cmo: %.ml
	$(OCAMLC) -c $<

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
toplevel.cmo: errors.cmi
iocaml_main.cmo: iocaml.cmi
iocaml.cmo: iocaml.cmi

