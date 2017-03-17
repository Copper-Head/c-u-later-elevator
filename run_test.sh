#!/usr/bin/env bash
set -e

# Run clingo on a test instance and prettify its output a bit with sed
clingo $1 elevator.lp | sed 's/) /)\n/g'
