import matplotlib.pyplot as plt
import glob

def read(filename):
    f = open(filename)
    count = 0
    total_time = 0.0
    lines = f.readlines()
    for l in lines:
        if "Elapse" not in l:
            continue
        time = l.split(": ")[1].split("ms")[0]
        time = float(time)
        count = count + 1
        total_time += time
    return total_time / count

def graph(time, client_count):
    plt.figure(figsize=(10, 6))

    plt.plot(client_count, time)

    plt.legend(loc='upper right')
    plt.title("Different fail rate' finish time with 4 clients and 10 participants")
    plt.xlabel('Fail to send probablity')
    plt.ylabel('Execution Time (ms)')
    plt.grid(True)
    plt.savefig(f'fail.png')


def custom_sort_key(file):
    return float(file.split("_")[1].split(".txt")[0])

def main():
    time = []
    prob_list = []
    files = glob.glob('fail_*.txt')
    files = sorted(files, key=custom_sort_key)
    # Print the list of matching files
    for file in files:
        time.append(read(file))
        prob = file.split("_")[1].split(".txt")[0]
        prob_list.append(float(prob))

    print(time)
    print(prob_list)
    graph(time, prob_list)
if __name__ == "__main__":
    main()