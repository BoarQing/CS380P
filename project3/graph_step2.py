import pandas as pd
import matplotlib.pyplot as plt

input = ["coarse.txt"]

data_all = [
    [
        [
            0.7370260869999999,
            0.458143103,
            0.37535325109999995,
            0.36127726690000006,
            0.38700740459999994,
            0.4156193322,
            0.457113224,
        ],
        [
            0.8400965401999999
        ],
        [
            0.8112133127
        ]
    ]
]


input_size = [100]

def get_all_range(num):
    ret = []
    cur = 2
    while cur < num:
        ret.append(cur)
        cur *= 2
    ret.append(num)
    return ret

def generate_image(idx):
    plt.figure(figsize=(10, 6))

    plt.plot(get_all_range(input_size[idx]),  data_all[idx][0], marker='o', linestyle='-', color='r', label='buffer@' + input[idx])
    plt.plot([input_size[0]], data_all[idx][1], marker='o', linestyle='-', color='b', label='matrix@' + input[idx])
    plt.plot([1], data_all[idx][2], marker='o', linestyle='-', color='g', label='sequential@' + input[idx])

    plt.legend(loc='lower left')
    plt.title("Different algorithms' comp time")
    plt.xlabel('Number of Goroutines')
    plt.xscale('log', base=2)
    plt.ylabel('Execution Time (s)')
    plt.grid(True)
    plt.savefig(f'step2.png')

if __name__ == "__main__":
    generate_image(0)