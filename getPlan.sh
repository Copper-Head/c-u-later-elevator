#!/bin/bash

encoding="elevator.lp"
# encoding="planner.lp"

if [ -z "$1" ]
  then
    echo "USAGE: ./getPlan.sh <instance> [<encoding>]"
  else
    if [ -n "$2" ]
    then
      encoding="$2"
    fi
    clingo $1 $encoding --outf=1 --quiet=1,0 | ./prettify.sh

fi
