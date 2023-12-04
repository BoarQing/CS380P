import matplotlib.pyplot as plt
import numpy as np

input_size = [10, 100, 1000, 10000]
program_name = [
    "naive",
    "barnehut",
    "mpi 1 node",
    "mpi 2 nodes",
    "mpi 4 nodes",
    "mpi 8 nodes",
    "mpi 16 nodes"
]

theta_0 = [
    [
        7.677077000000001e-05,
        0.001279592,
        0.001220704,
        0.001806736,
        0.008181571,
        0.01744081,
        0.44620810000000005,
    ],
    [
        0.004869701,
        0.011922349999999998,
        0.012401330000000002,
        0.009109492,
        0.013957259999999999,
        0.1270447,
        0.6506593,
    ],
    [
        0.4944856999999999,
        1.1188569999999998,
        1.106001,
        0.5578872,
        0.3203388,
        0.2963363,
        0.8880764000000001,
    ],
    [
        48.060719999999996,
        115.80340000000001,
        121.0073,
        57.904880000000006,
        28.398979999999995,
        17.9205,
        21.77686,
    ]
]
theta_0_5 = [
    [
        0,
        0.001287697,
        0.001332522,
        0.001642942,
        0.007776499000000001,
        0.13597057,
        0.5302338,
    ],
    [
        0,
        0.005602121,
        0.005817175,
        0.004700423,
        0.009973046,
        0.01864839,
        0.6160007,
    ],
    [
        0,
        0.09334564000000001,
        0.0964601,
        0.05596256999999999,
        0.038701059999999995,
        0.15846259,
        0.7780401000000001,
    ],
    [
        0,
        1.5841500000000002,
        1.615917,
        0.8551688000000002,
        0.4663206000000001,
        0.6119996999999999,
        1.5260453,
    ]
]


def generate_image(theta, arr):
    x = []
    l = len(arr[0])
    for i in range(l):
        x.append(i)

    plt.figure(figsize=(10, 6))
    beg = 0
    if theta != 0:
        beg = 1

    for i in range(beg, len(arr[0])):
        x = [1, 2, 3, 4]
        y = [row[beg] / row[i] for row in arr]
        
        plt.plot(x, y, label=program_name[i])
        plt.xticks(x, input_size, rotation=0, ha='center')
    plt.legend(loc='upper left')
    plt.xlabel('Input Size')
    plt.ylabel('Speed up (Sequential Time / Parallel Time)')
    plt.grid(True)
    plt.title(f"theta = {theta}")
    plt.savefig(f"theta_{theta}.png")

if __name__ == "__main__":
    generate_image(0, theta_0)
    generate_image(0.5, theta_0_5)