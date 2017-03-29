#!/bin/bash
# Chains together getPlan.sh and compare_solutions.py
# run like this:
# ./comparePlans.sh instance/instance-<number-etc>.lp

set -e
# encoding="planner.lp"
encoding="elevator.lp"

./getPlan.sh $encoding $1 | python compare_solution.py $1.sol
