# IOCamlJS 

The OCaml toplevel compiled to javascript and interfaced to the IPython notebook.

___This is very much a prototype currently and requires a lot more work___

Basic code execution and writing to stdout and stderr are working at the moment.

## To run the code

The javascript required to run the code is included in the repository.

```
ipython profile create iocamljs
cp -r static `ipython locate profile iocamljs`
ipython notebook --profile=iocamljs
```

## Building

To build the code you need to use the latest trunk version of `js_of_ocaml`.  You can
either manually install it, or use OPAM to pin the latest version.

```
opam pin js_of_ocaml git://github.com/ocsigen/js_of_ocaml
opam install js_of_ocaml
```

Once that is finished, you can rebuild the JavaScript by:

```
make
make install
```

The install command will cat together some JavaScript files, put the resulting
kernel in `static/services/kernels/js/kernel.js`, and then copy the `static`
directory tree to the `iocamljs` profile.

_Watch out for the browser caching old versions of the JavaScript code
(including from other ipython profiles) - in Chrome reload the page with
ctrl-shift-r._

