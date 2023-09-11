#!/usr/bin/env python3
import os
from subprocess import check_output
import re
import sys
from time import sleep

THREADS = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32]
LOOPS = [10, 100000]
INPUTS = ["1k.txt", "8k.txt", "16k.txt", "seq_64_test.txt"]
repeat = 1

def calc(input_file, thread_count, min_loop, max_loop):
    sleep(0.5)
    mid_loop = int((max_loop - min_loop) / 2 + min_loop)
    print(f"{thread_count} {mid_loop} {max_loop} {min_loop} {input_file}")

    if (mid_loop == min_loop or mid_loop == max_loop):
        return mid_loop
    cmd = "./bin/prefix_scan -o temp.txt -n {} -i tests/{} -l {}".format(
    thread_count, input_file, mid_loop)
    out = check_output(cmd, shell=True).decode("ascii")
    m = re.search("time: (.*)", out)
    parallel_time = int(m.group(1))

    sleep(0.5)
    cmd = "./bin/prefix_scan -o temp.txt -n {} -i tests/{} -l {}".format(
    str(0), input_file, mid_loop)
    out = check_output(cmd, shell=True).decode("ascii")
    m = re.search("time: (.*)", out)
    sequential_time = int(m.group(1))

    print(parallel_time, sequential_time)
    max_time = max(parallel_time, sequential_time)
    min_time = min(parallel_time, sequential_time)
    diff = max_time - min_time
    if diff / max_time < 0.03:
        return mid_loop
    else:
        if parallel_time > sequential_time:
            return calc(input_file, thread_count, mid_loop, max_loop)
        else:
            return calc(input_file, thread_count, min_loop, mid_loop)

def generate_csv():
    csvs = []
    for inp in INPUTS:
        csv = ["{}".format(inp)]
        for thr in THREADS:

            time = calc(inp, thr, LOOPS[0], LOOPS[1])
            csv.append(str(time))

        csvs.append(csv)

    header = ["thread"] + [str(x) for x in THREADS]
    print("\n")
    print(", ".join(header))
    for csv in csvs:
        print (", ".join(csv))






if __name__ == "__main__":
    generate_csv()