import sys
import random



def gen_input(count, dim, centroid):
    filename = f"input/generated_input_n{count}_d{dim}_c{centroid}.txt"
    f = open(filename, "w")
    f.write(str(count) + '\n')
    for i in range(count):
        line = str(i + 1)
        for j in range(dim):
            random_float = random.random()
            line += ' ' + str(random_float)
        f.write(line + '\n')
    f.close()

def main():
    count = int(sys.argv[1])
    dim = int(sys.argv[2])
    centroid = int(sys.argv[3])
    gen_input(count, dim, centroid)


if __name__ == "__main__":
    main()

