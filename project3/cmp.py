import sys

def GetDict(filename):
    hash = {}
    group = {}
    f = open(filename, "r")
    lines = f.readlines()
    for l in lines:
        if "hashGroupTime:" in l or "compareTreeTime:" in l:
            continue
        l = l.strip()
        if "group" not in l:
            ints = l.split(":")
            key = int(ints[0])
            ints = ints[1].strip().split(" ")
            int_list = sorted([int(i) for i in ints])
            hash[key] = int_list
        else:
            ints = (l.split(":")[1]).strip().split(" ")
            int_list = sorted([int(i) for i in ints])
            l = str(int_list)
            group[l] = True
    return hash, group

def Cmp(a, b):
    for key in a:
        if key not in b or a[key] != b[key]:
            print(f"diff for string {key} {a[key]}")
    for key in b:
        if key not in a or a[key] != b[key]:
            print(f"diff for string {key} {b[key]}")

def main():
    go_file = sys.argv[1]
    py_file = sys.argv[2]
    h1, g1 = GetDict(go_file)
    h2, g2 = GetDict(py_file)
    Cmp(h1, h2)
    Cmp(g1, g2)
if __name__ == "__main__":
    main()