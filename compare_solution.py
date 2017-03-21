import argparse
import fileinput
import sys

"""
Hacky script for comparing output set to gold set.

Usage: ./getPlan.sh elevator_lisa.lp instance 0 | \
        python compare_solution.py instance_solution
"""


def compare_sets(s1, s2):
    """Compare the sets."""
    if len(s1) != 0:
        return s1 == s2
    return False


def read_from_stdin():
    """Collect piped elements in set."""
    s1 = set()

    for line in fileinput.input():
        s1.add(line.strip())

    return s1


def read_from_file(file_name):
    """Collect elements from solution in set."""
    s2 = set()
    with open(file_name, "r") as f:
        for line in f:
            s2.add(line.strip())
    return s2


if __name__ == "__main__":

    print(sys.argv[1])
    print(sys.argv[2])

    s1 = read_from_file(sys.argv[1])
    print(s1)
    s2 = read_from_file(sys.argv[2])
    print(s2)

    print("\ncorrect solution: {}\n".format(compare_sets(s1, s2)))
