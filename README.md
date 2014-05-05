![IOCaml logo](http://github.com/andrewray/iocamlserver/raw/master/logos/IOlogoJS.png "IOCaml logo")

# IOCamlJS 

IOCaml is an OCaml kernel for the 
[IPython notebook](http://ipython.org/notebook.html). 
This provides a REPL within a web browser with a nice user interface 
including markdown based comments/documentation, mathjax formula and 
the possibility of generating all manner of HTML based output media 
from your code.  

See also

* [IOCaml-kernel](https://github.com/andrewray/iocaml)
* [IOCamlJS-kernel](https://github.com/andrewray/iocamljs)
* [IOCaml-server](https://github.com/andrewray/iocamlserver)

This repository hosts the iocamljs-kernel package.

With this kernel the OCaml REPL is compiled to JavaScript and run in the
browser.

The demo notebook `js_of_ocaml-webgl-demo.ipynb` provides a good example of what 
can be done.  Its an almost direct copy of the 
[js\_of\_ocaml WebGL demo](http://ocsigen.org/js_of_ocaml/files/webgl/index.html) except
the 3d model, shader code, ocaml code and html code are all embedded in the notebook
and can be compiled and run live in the browser.

When run using the [IOCaml server](https://github.com/andrewray/iocamlserver) the 
toplevel can support file I/O including dynamic loading of libraries using
topfind ```#require``` directives.

## Installation

```
$ opam install iocaml
```

or to just get the kernel

```
$ opam install iocamljs-kernel
```

Precompiled versions which can be used with the [Enthought](https://www.enthought.com/downloads/) 
IPython distribution on Windows can be downloaded from 
[here](https://github.com/andrewray/iocamljs/releases/download/v0.4/static.tar.gz).

