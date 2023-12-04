import sys

def read_file(path):
    ret = {}
    with open(path, 'r') as file:
        row_count = int(file.readline().strip())
        for _ in range(row_count):
            row = file.readline().strip()
            val = row.split()
            idx = int(val[0])
            x = float(val[1])
            y = float(val[2])
            mass = float(val[3])
            x_vel = float(val[4])
            y_vel = float(val[5])
            ret[idx] = {"x" : x, "y" : y, "mass" : mass, "x_vel" : x_vel, "y_vel" : y_vel}
    return ret

def cmp(d1, f1, d2, f2):
    match = True
    for idx in d1:
        k1 = d1[idx]
        k2 = d2[idx]
        for key in k1:
            if abs(k1[key] - k2[key]) > 1e-05 :
                print(f"{f1} and {f2} mismatched at index {idx} key {key} with difference of {k1[key] - k2[key]}")
                match = False
    if match:
        print(f"{f1} and {f2} matched")
            
def main():
    d1 = read_file(sys.argv[1])
    d2 = read_file(sys.argv[2])
    cmp(d1, sys.argv[1], d2, sys.argv[2])

if __name__ == "__main__":
    main()
