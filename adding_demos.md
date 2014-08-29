---
layout: slate
title: IOCamlJS Demos
description: Adding a demo notebook
---

Fork [IOCamlJS](https://github.com/andrewray/iocamljs) and switch to the gh-pages branch.

Create the new notebook in the notebooks subdirectory.

~~~
$ iocaml -js min notebooks/my_demo.ipynb -no-split-lines
~~~

Note we require the -no-split-lines option to save the notebook in a format understood
by iocamljs when used without the server.  Just ensure the notebook is saved this way
before publishing.

Add a new html file to the project `my_demo.html` with the following contents

~~~
---
layout: iocamljs
notebook_guid: "my_demo.ipynb"
kernel: min
---
~~~

The notebook_guid parameter should point to the newly created notebook.  The kernel
parameter selects which iocamljs kernel will run.  Here `min` refers to the kernel
`static/services/kernels/js/kernel.min.js`.  You can also add new kernels with custom 
package sets if required.

Finally add the link to the landing page in index.md

~~~
* [My demo](my_demo.html)
~~~

Send a pull request.
