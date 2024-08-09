#!/usr/bin/env bash

name=$1
chmod 777 "$name"
patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 --set-rpath /lib/x86_64-linux-gnu "$name"
