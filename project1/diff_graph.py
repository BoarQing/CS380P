import pandas as pd
import matplotlib.pyplot as plt

def generate_image(df, pthread, reent, loop):
    thread_count = [int(col) for col in df.columns[1:]]
    pthread_runtime_1k = df[df['microseconds'] == (pthread + '/1k.txt/' + str(loop))].values[0][1:]
    pthread_runtime_8k = df[df['microseconds'] == (pthread + '/8k.txt/' + str(loop))].values[0][1:]
    pthread_runtime_16k = df[df['microseconds'] == (pthread + '/16k.txt/' + str(loop))].values[0][1:]
    pthread_runtime_64 = df[df['microseconds'] == (pthread + '/seq_64_test.txt/' + str(loop))].values[0][1:]

    reent_runtime_1k = df[df['microseconds'] == (reent + '/1k.txt/' + str(loop))].values[0][1:]
    reent_runtime_8k = df[df['microseconds'] == (reent + '/8k.txt/' + str(loop))].values[0][1:]
    reent_runtime_16k = df[df['microseconds'] == (reent + '/16k.txt/' + str(loop))].values[0][1:]
    reent_runtime_64 = df[df['microseconds'] == (reent + '/seq_64_test.txt/' + str(loop))].values[0][1:]

    plt.figure(figsize=(10, 6))
    plt.plot(thread_count, pthread_runtime_1k, marker='o', linestyle='-', color='r', label='pthread_1k')
    plt.plot(thread_count, pthread_runtime_8k, marker='o', linestyle='-', color='g', label='pthread_8k')
    plt.plot(thread_count, pthread_runtime_16k, marker='o', linestyle='-', color='b', label='pthread_16k')
    plt.plot(thread_count, pthread_runtime_64, marker='o', linestyle='-', color='gray', label='pthread_64')

    plt.plot(thread_count, reent_runtime_1k, marker='x', linestyle='-', color='r', label='reent_1k')
    plt.plot(thread_count, reent_runtime_8k, marker='x', linestyle='-', color='g', label='reent_8k')
    plt.plot(thread_count, reent_runtime_16k, marker='x', linestyle='-', color='b', label='reent_16k')
    plt.plot(thread_count, reent_runtime_64, marker='x', linestyle='-', color='gray', label='reent_64')

    plt.legend(loc='upper right')

    plt.title(f'Execution Time vs. Number of Threads of loop size {str(loop)}')
    plt.xlabel('Number of Threads')
    plt.ylabel('Execution Time (ms)')
    plt.grid(True)
    plt.savefig(f'diff_{loop}.png')


if __name__ == "__main__":
    df = pd.read_csv('runtime.csv')
    print(df)

    generate_image(df, "pthread barriers", "own re-entrant barrier", 10)
    generate_image(df, "pthread barriers", "own re-entrant barrier", 100000)

