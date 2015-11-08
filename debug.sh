#!/bin/bash
set -ex
sedexpr="$( grep '//.*debug_.*->' c3demo.v | sed 's,.*\(debug_\),s/\1,; s, *-> *, /,; s, *$, /;,;'; )"
ssh pi@raspi 'icoprog -V16' | sed -e "$sedexpr" > debug.vcd
