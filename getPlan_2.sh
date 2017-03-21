#!/bin/bash

SCRIPT_PATH="compare_solution.py"
PYTHON="/usr/bin/python3"

encoding="elevator_lisa.lp"
solution_file="solution.sol"

if [ -z "$1" ]
  then
    echo "USAGE: ./getPlan.sh <instance> [<encoding>]"
  else
    if [ -n "$2" ]
    then
      encoding="$2"
    fi
    clingo $1 $encoding --outf=1 --quiet=1,0 | grep -A1 ANSWER | tail -n1 | tr " " "\n" > $solution_file


fi


# python test gold