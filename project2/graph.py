import pandas as pd
import matplotlib.pyplot as plt

executable = ["sequential", "cuda_basic", "cuda_shmem", "thrust"]
color = ["gray", "r", "g", "b"]

def generate_image():
    runtime_pair = []
    with open("runtime.txt") as f:
        for line in f:
            if line == "\n":
                continue
            word = line.split(": ")
            e_f = word[0][len("result/"):]
            t = word[1][:-1]
            for e in executable:
                if e not in e_f:
                    continue
                runtime_pair.append((e, int(e_f[len(e) + 1:]), float(t)))

    plt.figure(figsize=(10, 6))
    for i in range(len(executable)):
        e = executable[i]
        time = []
        input = []
        for p in runtime_pair:
            if (p[0] != e):
                continue
            input.append(p[1])
            time.append(p[2])
        c = color[i]
        print(time, input, e)
        plt.plot(input, time, marker='o', linestyle='-', color=c, label=e) 

    plt.legend(loc='upper right')

    plt.title("Different algorithms' finish time on various input size")
    plt.xlabel('Number of Inputs')
    plt.ylabel('Execution Time (ms)')
    plt.grid(True)
    plt.savefig(f'performance.png')


if __name__ == "__main__":
    generate_image()

