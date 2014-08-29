---
layout: slate
title: IOCamlJS Demos
description: Compiling a new kernel
---

`iocamljs-kernel.0.4.6` now builds using a tool from `js_of_ocaml` called `jsoo_mktop`.
Additionally the package installs a library which allows custom iocamljs top levels 
to be built.

The `jsoo_mktop` program (version 2.4.1) takes the following arguments

~~~
Usage: jsoo_mktop [options] [ocamlfind arguments] 
 -verbose			Output intermediate commands
 -help				Display usage
 -top-syntax [pkg]		Include syntax extension provided by [pkg] findlib package
 -top-syntax-mod [mod]		Include syntax extension provided by the module [mod]
 -o [name]			Set output filename
 -jsopt [opt]			Pass [opt] option to js_of_ocaml compiler
 -export-package [pkg]		Compile toplevel with [pkg] package loaded
 -export-unit [unit]		Export [unit]
 -dont-export-unit [unit]	Dont export [unit]
~~~

The following invocation will build a basic iocaml toplevel

~~~
$ jsoo_mktop -dont-export-unit gc -export-package iocamljs-kernel \
    -jsopt +weak.js -jsopt +toplevel.js -o iocaml.byte
~~~

This will create a few files named `*.cmis.js` and `iocaml.js`.  These need to 
be packed together with `kernel.js` to create the final iocamljs kernel.

~~~
$ cat *.cmis.js \
  `opam config var lib`/iocamljs-kernel/kernel.js iocaml.js > \
  `opam config var share`/iocamljs-kernel/profile/static/services/kernels/js/kernel.min.js
~~~

To include other packages add more `-export-package` declarations.  You may need to
manually export some extra modules with `-export-unit` (this requires a bit of trial and
error - load the kernel, watch the messages in the browser console and see whats missing).

Syntax extensions can also be added with `-top-syntax`.

A more complex example with js_of_ocaml, lwt, syntax extensions and uuidm.

~~~
$ jsoo_mktop -dont-export-unit gc \
		-top-syntax lwt.syntax \
		-top-syntax js_of_ocaml.syntax \
		-export-package lwt \
		-export-package js_of_ocaml \
		-export-package uuidm \
    -export-package iocamljs-kernel \
    -jsopt +weak.js -jsopt +toplevel.js -o iocaml.byte
~~~


