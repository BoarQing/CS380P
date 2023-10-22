import pandas as pd
import matplotlib.pyplot as plt

input = ["fine.txt", "coarse.txt"]

data_hash_worker = [[
    0.017819715300000004,
    0.0090728615,
    0.0060679389,
    0.0053898721,
    0.004786566799999999,
    0.0039273938,
    0.0051888448,
    0.0044927988,
    0.0049418634000000005,
    0.0048674806,
    0.0050311021,
    0.0050414801,
    0.006157572900000001,
    0.007252672100000001,
    0.0071510826,
    0.012292280600000002,
    0.024292782,
    0.0379725449,
],
[
    0.046585063200000006,
    0.0239000091,
    0.014368418999999999,
    0.01173568,
    0.0112368278,
    0.0105733615,
    0.0099399593,
    0.0106248035,
]]

data_each = [[0.035521576699999995],
             [0.009825548700000002]]

input_size = [100000, 100]

def get_all_range(num):
    ret = []
    cur = 1
    while cur < num:
        ret.append(cur)
        cur *= 2
    ret.append(num)
    return ret

def generate_image():
    plt.figure(figsize=(10, 6))

    plt.plot(get_all_range(input_size[0]), data_hash_worker[0], marker='o', linestyle='-', color='r', label='hash_worker@' + input[0])
    plt.plot([input_size[0]], [data_each[0]], marker='o', linestyle='-', color='b', label='goroutine_for_each_tree@' + input[0])

    plt.plot(get_all_range(input_size[1]), data_hash_worker[1], marker='o', linestyle=':', color='r', label='hash_worker@' + input[1])
    plt.plot([input_size[1]], [data_each[1]], marker='o', linestyle=':', color='b', label='goroutine_for_each_tree@' + input[1]) 

    plt.legend(loc='upper left')
    plt.title("Different goroutines' hash time")
    plt.xlabel('Number of Goroutines')
    plt.xscale('log', base=2)
    plt.ylabel('Execution Time (s)')
    plt.grid(True)
    plt.savefig('step1_hash.png')

if __name__ == "__main__":
    generate_image()