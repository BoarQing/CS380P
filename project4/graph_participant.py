import matplotlib.pyplot as plt

def read(idx):
    filename = "parti_" + str(idx) + ".txt"
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
    plt.title("Different pariticpants' finish time with 4 clients")
    plt.xlabel('Number of participants')
    plt.ylabel('Execution Time (ms)')
    plt.grid(True)
    plt.savefig(f'participant.png')

def main():
    time = []
    p_count = []
    for i in range(1, 33):
        time.append(read(i))
        p_count.append(i)
    graph(time, p_count)
if __name__ == "__main__":
    main()