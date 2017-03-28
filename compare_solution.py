import argparse
import fileinput
import sys
import re
"""
Hacky script for comparing output set to gold set.

Usage:
1) ./getPlan_2.sh elevator_lisa.lp instance 0
2) python compare_solution.py solution.sol instances/instance.sol

"""


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
    # 'do(elevator(2),serve,62).'
    # t = ('do(elevator(2),serve,62).', 62)
    modified_set = []
    for i in s:
        time_step = int(re.search("(\d{1,4})\)\.", i).group(1))
        modified_set.append((i, time_step))
    # return sorted(modified_set, key=lambda x: x[1])
    return [i[0] for i in sorted(modified_set, key=lambda x: x[1])]


def file2set(file_obj):
    """Collect elements from solution in set."""
    return set(line.strip() for line in file_obj)


def read_from_file(file_name):
    with open(file_name, "r") as f:
        return file2set(f)


if __name__ == "__main__":

    prs = argparse.ArgumentParser()
    prs.add_argument('expected')
    prs.add_argument('ours', nargs="?")
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
