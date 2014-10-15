---
layout: slate
title: IOCamlJS Demos
description: Creating a new static site
---

`iocaml` can automatically create the files requires for a simple
static site with the following features 

* one or more notebooks
* a single (user configurable) iocamljs kernel
* configurable site root path

To get started we would use the standard iocaml server 
to create some notebooks with a potentially 
[custom kernel](compiling_kernels.html).

~~~
$ iocaml -js my_test_kernel my_notebooks/
~~~

Once happy with the notebooks a site can be created

~~~
$ iocaml -js my_test_kernel my_notebooks/ \
    -create-static-site my_site_dir \
    -static-site-base-path /online_dir
~~~

The site will be created in `my_site_dir`.  

The option `-static-site-base-path` configures the internal links within the 
generated html to allow the notebooks to be hosted at an arbitrary url path 
on the server.  If left out then the notebooks will be served from the
root url.

* For a `gh-pages` project site you would use `-static-site-base-path /project_name`
* You can also serve directly from the file system.  Say the site is generated in 
`/my/path`.  Using `-static-site-base-path "file:///my/path"` will allow you to test
the site from the browser directly.  _note; chromium-browser should be started
with the option `--allow-file-access-from-files`_.

