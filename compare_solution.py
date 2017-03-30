#!/usr/bin/env python
"""
Hacky script for comparing output set to gold set.

Usage:
just run python compare_solution.py -h

"""
import argparse
import fileinput
import sys
import re


def compare_sets(s1, s2):
    """Compare the sets."""
    if len(s1) != 0:
        # return s1 == s2
        return s1 - s2
    return False


def read_from_stdin():
    """Collect piped elements in set."""
    s1 = set()

    for line in fileinput.input():
        s1.add(line.strip())

    return s1


def order_output(s):
    time_step_matches = (re.search("(\d{1,4})\)\.", i) for i in s)
    time_steps = ((item, int(m.group(1)))
                  for m, item in zip(time_step_matches, s) if m)
    return [i[0] for i in sorted(time_steps, key=lambda x: x[1])]


def file2set(file_obj):
    """Turn lines in a file into a set."""
    return set(line.strip() for line in file_obj)


def read_from_file(file_name):
    """Read set from a file"""
    with open(file_name, "r") as f:
        return file2set(f)


if __name__ == "__main__":

    prs = argparse.ArgumentParser()
    prs.add_argument('expected', help="Name of gold standard file")
    prs.add_argument(
        'ours',
        nargs="?",
        help="Name of our output. "
        "If not given, stdin is used.")
    args = prs.parse_args()

    expected_set = read_from_file(args.expected)
    if args.ours:
        our_set = read_from_file(args.ours)
    else:
        our_set = file2set(sys.stdin)

    # print("\ncorrect solution: {}\n".format(compare_sets(test, gold)))
    # print("\ndifferences in set 1 and set 2:\n\n {}\n".format(compare_sets(test, gold)))

    test_ordered = order_output(our_set - expected_set)
    gold_ordered = order_output(expected_set - our_set)

    with open("our-output.lp", "w") as f:
        f.write("\n".join(test_ordered))

    with open("expected-output.lp", "w") as f:
        f.write("\n".join(gold_ordered))
