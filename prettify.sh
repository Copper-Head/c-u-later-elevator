#!/usr/bin/env bash

set -e

# This will only work if clingo was invoked with --outf=1
grep -A1 ANSWER $1 | tail -n1 | tr " " "\n"