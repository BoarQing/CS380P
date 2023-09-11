#!/usr/bin/env python3
import os
from subprocess import check_output
import re
from time import sleep

THREADS = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32]
LOOPS = [10, 500000]
INPUTS = ["1k.txt", "8k.txt", "16k.txt", "seq_64_test.txt"]
OPTIONS = ["-s", ""]
repeat = 5

def generate_csv():
    csvs = []
    for op in OPTIONS:
        for inp in INPUTS:
            for loop in LOOPS:
                spin_str = "own re-entrant barrier" if len(op) > 0 else "pthread barriers"
                csv = ["{}/{}/{}".format(spin_str, inp, loop)]
                for thr in THREADS:
                    total_time = 0
                    for r in range(repeat):
                        cmd = "./bin/prefix_scan -o temp.txt {} -n {} -i tests/{} -l {}".format(
                            op, thr, inp, loop)
                        out = check_output(cmd, shell=True).decode("ascii")
                        m = re.search("time: (.*)", out)
                        if m is not None:
                            time = m.group(1)
                            total_time += int(time)
                    total_time = str(total_time // repeat)
                    csv.append(total_time)

                csvs.append(csv)
                sleep(0.5)

    header = ["microseconds"] + [str(x) for x in THREADS]
    print("\n")
    print(", ".join(header))
    for csv in csvs:
        print (", ".join(csv))






if __name__ == "__main__":
    generate_csv()