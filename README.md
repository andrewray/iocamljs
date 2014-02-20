# IOCamlJS 

The OCaml toplevel compiler to javascript and interfaced to the IPython notebook.

___This is very much a prototype currently and requires a lot more work___

To build the code you need to download the source tarball of js-of-ocaml.  Edit the
top of the Makefile to point to it.

_You might need to compile this with the version of js-of-ocaml built from the tarball - not too sure on this._

The resulting iocaml.js file should be copied to `static/custom/custom.js`.

To run the code

```
ipython profile create iocamljs
cp -r static `ipython profile locate iocamljs`
ipython notebook --profile=iocamljs
```
