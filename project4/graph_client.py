import matplotlib.pyplot as plt

def read(idx):
    filename = "client_" + str(idx) + ".txt"
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
    plt.title("Different clients' finish time with 10 pariticpants")
    plt.xlabel('Number of clients')
    plt.ylabel('Execution Time (ms)')
    plt.grid(True)
    plt.savefig(f'client.png')

def main():
    time = []
    client_count = []
    my_range = [1, 2, 4, 8, 16, 32]
    for i in my_range:
        time.append(read(i))
        client_count.append(i)
    graph(time, client_count)
if __name__ == "__main__":
    main()