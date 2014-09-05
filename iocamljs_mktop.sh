#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Uasge: $0 <kernel name> [args]"
  exit 1
fi

KERNEL=$1
shift 1
jsoo_mktop -dont-export-unit unix "$@" -export-package iocamljs-kernel -jsopt +weak.js -jsopt +toplevel.js -o iocaml.byte
cat *.cmis.js \
  `opam config var lib`/iocamljs-kernel/kernel.js iocaml.js > \
  `opam config var share`/iocamljs-kernel/profile/static/services/kernels/js/kernel.$KERNEL.js

