import subprocess
import time
REPEAT = 10
PROC_COUNT = [1, 2, 4, 8, 16]
input_file = ["../input/nb-10.txt", "../input/nb-100.txt", "../input/nb-1000.txt", "../input/nb-10000.txt"]
step = [1, 1, 1, 1]

def timing_loop(exec, file_idx, theta):
    total_time = 0
    cmd = f"{exec} -i {input_file[file_idx]} -o ../output/tmp.txt -t {theta} -d 0.005 -s {step[file_idx]}"
    for _ in range(REPEAT):
        elapse = subprocess.check_output(cmd, shell=True).decode("ascii").strip()
        total_time += float(elapse)
        time.sleep(0.5)
    print(f"{exec}: {total_time} {input_file[file_idx]} {theta}")

    
def timing(theta):
    for i in range(len(input_file)):
        if theta == 0.0:
            timing_loop("./nbody_naive", i, theta)
        timing_loop("./nbody_barnehut", i, theta)
        for p in PROC_COUNT:
            timing_loop(f"mpirun -np {p} ./nbody_mpi", i, theta)
def main():
    timing(0)
    timing(0.5)

if __name__ == "__main__":
    main()
