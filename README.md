# IOCamlJS 

IOCamlJS runs a (compiled-to-javascript) OCaml REPL in the IPython notebook.
`stdout` and `stderr` are redirected to the notebook interface so 
`printf` works as expected.  The `js_of_ocaml` and `lwt` syntax 
extensions are enabled.

Only a small API for interacting with the notebook is provided by `iocamljs` at 
the moment; `js_of_ocaml` provides far greater possibilities.

The demo notebook `js_of_ocaml-webgl-demo.ipynb` provides a good example of what 
can be done.  Its an almost direct copy of the 
[js_of_ocaml WebGL demo](http://ocsigen.org/js_of_ocaml/files/webgl/index.html) except
the 3d model, shader code, ocaml code and html code are all embedded in the notebook
and can be compiled and run live in the browser.

## To run the code

The javascript required to run the code is included in the repository.  Nothing needs
to be compiled - just do the following (assuming you have IPython 1.1 installed, otherwise
see [iocaml](https://github.com/andrewray/iocaml) for help).

```
ipython profile create iocamljs
cp -r static `ipython locate profile iocamljs`
ipython notebook --profile=iocamljs
```

## Building

__Watch out for the browser caching old versions of JavaScript code
(including from other ipython profiles) - in Chrome reload the page with
ctrl-shift-r.__

To build the code you need to use the latest trunk version of `js_of_ocaml`.  You can
either manually install it, or use OPAM to pin the latest version.

```
opam pin js_of_ocaml git://github.com/ocsigen/js_of_ocaml
opam install js_of_ocaml
```

Once that is finished, you can rebuild the JavaScript with:

```
make
```

which creates `static/services/kernels/js/kernel.js` and

```
make install
```

which then copies the `static` directory tree to the `iocamljs` profile.

To add the syntax extensions you should build

```
make top
```

## Adding libraries

Preliminary support for topfind has been tested.  This requires the use
of [IOCamlServer](https://github.com/andrewray/iocamlserver) which will
be release soon (it works but requires some updated packages to build).
This allows libraries to be loaded interactively within the notebook
interface.

Alternatively libraries may be built into IOCamlJS itself.  See the
makefile for more information about how this works.
