import sys


def GetList(file_path):
    lists = []
    with open(file_path, "r") as file:
        lines = file.readlines()
    for line in lines:
        num_list = list(map(int, line.split()))
        lists.append(num_list)
    return lists

def hash(l):
    sorted_list = sorted(l)
    h = 1
    for val in sorted_list:
        new_val = val + 2
        h = (h * new_val + new_val) % 1000
    return h

def PrintHash(d):
    for key in d:
        if len(d[key]) <= 1:
            continue
        print(f"{key}:",end='')
        for a in d[key]:
            print(f" {a}", end='')
        print()

def GetHashList(tree_list):
    ret = {}
    for i in range(len(tree_list)):
        h = hash(tree_list[i])
        if h in ret:
            ret[h].append(i)
        else:
            ret[h] = [i]
    return ret

def GetCmpList(hash_list, tree_list):
    cmp_list = {}
    visted = {}
    for h in hash_list.values():
        for i in range(len(h)):
            id1 = h[i]
            if id1 in visted:
                continue
            t1 = sorted(tree_list[id1])
            for j in range(i + 1, len(h)):
                id2 = h[j]
                if id2 in visted:
                    continue
                t2 = sorted(tree_list[id2])
                if t1 == t2:
                    visted[id1] = True
                    visted[id2] = True
                    if id1 not in cmp_list:
                        cmp_list[id1] = [id1]
                    cmp_list[id1].append(id2)
    return cmp_list

def PrintCmp(d):
    idx = 0
    for v in d.values():
        if len(v) < 2:
            continue
        print(f"group {idx}:", end='')
        for n in v:
            print(f" {n}", end='')
        print()
        idx += 1

def main():
    tree_list = GetList(sys.argv[1])
    hash_list = GetHashList(tree_list)
    PrintHash(hash_list)
    cmp_list = GetCmpList(hash_list, tree_list)
    PrintCmp(cmp_list)

if __name__ == "__main__":
    main()