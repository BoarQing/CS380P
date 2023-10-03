import sys
import math
def read_centroid(file):
    f = open(file, 'r')
    centroid = []
    for line in f:
        if "," in line:
            continue
        line = line.strip().split()
        if len(line) > 1:
            point = [float(x) for x in line[1:]]
            centroid.append(point)
    return centroid

def cmp(filename, data1, data2):
    for i in range(len(data1)):
        pt1 = data1[i]
        pt2 = data2[i]
        for j in range(len(pt1)):
            diff = abs(pt1[j] - pt2[j])
            if (diff > 10e-4):
                print(f"file {filename}: error at centroid {i} dim {j} is {diff}, {pt1[j]} vs {pt2[j]}")

def read_label(file):
    f = open(file, 'r')
    for line in f:
        if "," in line:
            continue
        return line

def cmp_label_file(file1, file2):
    data1 = read_label(file1)
    data2 = read_label(file2)
    if data1 != data2:
        print(f"file {file1} {file2}: diff")

def cmp_file(file1, file2):
    data1 = read_centroid(file1)
    data2 = read_centroid(file2)
    cmp(file1, data1, data2)
