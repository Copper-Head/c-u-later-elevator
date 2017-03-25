#!/bin/bash

encoding="elevator.lp"
end=2

if [ -z "$1" ]
  then
    echo "USAGE: ./getPlan.sh <instance> [<encoding>]"
  else
    if [ -n "$2" ]
    then
      encoding="$2"
      end=3
    fi
    clingo $1 $encoding --outf=1 --quiet=1,0 ${@:$end} | grep -A1 ANSWER | tail -n1 | tr " " "\n"

fi
