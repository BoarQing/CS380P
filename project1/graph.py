import pandas as pd
import matplotlib.pyplot as plt

def generate_image(df, spin_str, loop):
    thread_count = [int(col) for col in df.columns[1:]]
    runtime_1k = df[df['microseconds'] == (spin_str + '/1k.txt/' + str(loop))].values[0][1:]
    runtime_8k = df[df['microseconds'] == (spin_str + '/8k.txt/' + str(loop))].values[0][1:]
    runtime_16k = df[df['microseconds'] == (spin_str + '/16k.txt/' + str(loop))].values[0][1:]
    runtime_64 = df[df['microseconds'] == (spin_str + '/seq_64_test.txt/' + str(loop))].values[0][1:]

    plt.figure(figsize=(10, 6))
    plt.plot(thread_count, runtime_1k, marker='o', linestyle='-', color='r', label='1k')
    plt.plot(thread_count, runtime_8k, marker='o', linestyle='-', color='g', label='8k')
    plt.plot(thread_count, runtime_16k, marker='o', linestyle='-', color='b', label='16k')
    plt.plot(thread_count, runtime_64, marker='o', linestyle='-', color='gray', label='64')

    plt.legend(loc='upper right')

    plt.title(f'Execution Time vs. Number of Threads with loop of {loop} and {spin_str}')
    plt.xlabel('Number of Threads')
    plt.ylabel('Execution Time (ms)')
    plt.grid(True)
    plt.savefig(f'{spin_str}_{loop}.png')


if __name__ == "__main__":
    df = pd.read_csv('runtime.csv')
    print(df)

    generate_image(df, "own re-entrant barrier", 10)
    generate_image(df, "pthread barriers", 10)
    generate_image(df, "own re-entrant barrier", 100000)
    generate_image(df, "pthread barriers", 100000)

