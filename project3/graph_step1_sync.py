import pandas as pd
import matplotlib.pyplot as plt

input = ["fine.txt", "coarse.txt"]

data_all = [
    [
        [
            0.031809775,
            0.021201855900000004,
            0.015969030099999997,
            0.014144372900000002,
            0.013040427399999999,
            0.0123027291,
            0.012125878399999998,
            0.012739726500000001,
            0.012457281099999998,
            0.014809404300000004,
            0.014458588900000003,
            0.013942135900000003,
            0.0151966417,
            0.014520859,
            0.0171743559,
            0.020917097500000002,
            0.031156925000000002,
            0.04328832579999999,
        ],
        [
            0.032307151,
            0.0224168027,
            0.0166627425,
            0.0155128665,
            0.0132112825,
            0.012795458799999998,
            0.0138828537,
            0.012702813399999999,
            0.0131305325,
            0.016699118399999997,
            0.018156921700000002,
            0.019388714799999998,
            0.0215092612,
            0.024534380699999997,
            0.0316765197,
            0.0422545482,
            0.054618173199999995,
            0.053538565999999996,
        ],
        [
            0.027267336
        ]
    ],
    [
        [
            0.04775640540000001,
            0.024762974400000002,
            0.017340175300000003,
            0.0132393335,
            0.011802865699999998,
            0.0125774785,
            0.011650982,
            0.011659172200000002,
        ],
        [
            0.04745174059999999,
            0.0262108991,
            0.018072702200000002,
            0.013578346200000002,
            0.012393242600000002,
            0.0116190214,
            0.011028311499999999,
            0.012111568,
        ],
        [
            0.04734956
        ]
    ]
]


input_size = [100000, 100]

def get_all_range(num):
    ret = []
    cur = 1
    while cur < num:
        ret.append(cur)
        cur *= 2
    ret.append(num)
    return ret

def generate_image(idx):
    plt.figure(figsize=(10, 6))

    plt.plot(get_all_range(input_size[idx]),  data_all[idx][0], marker='o', linestyle='-', color='r', label='channel@' + input[idx])
    plt.plot(get_all_range(input_size[idx]), data_all[idx][1], marker='o', linestyle='-', color='b', label='lock@' + input[idx])
    plt.plot([1], data_all[idx][2], marker='o', linestyle='-', color='g', label='sequential@' + input[idx])

    plt.legend(loc='upper right')
    plt.title("Different algorithms' hash time with sync")
    plt.xlabel('Number of Goroutines')
    plt.xscale('log', base=2)
    plt.ylabel('Execution Time (s)')
    plt.grid(True)
    plt.savefig(f'step1_sync_{input[idx]}.png')

if __name__ == "__main__":
    generate_image(0)
    generate_image(1)