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

To build the code you need to download and build the source tarball of js-of-ocaml.  Edit the
top of the Makefile to point to it.

_You might need to compile this with the version of js-of-ocaml built from the tarball._

```
make
make install
```

The install command will cat together some javascript files, put the resulting kernel in
`static/services/kernels/js/kernel.js` then copy the `static` directory tree to
the `iocamljs` profile.

_Watch out for the browser caching old versions of the javascript code (including from other ipython profiles) - in Chrome reload the page with ctrl-shift-r._

