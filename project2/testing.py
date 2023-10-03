import subprocess
import time
from diff import cmp_file, cmp_label_file

REPEAT = 10
SEED = 8675309
ITER = 150
TOL = 0.00001
input = [
    ("input/cs.utexas.edu_~rossbach_cs380p_lab_kmeans-sample-inputs_random-n2048-d16-c16.txt", 16, 16, 2048, "golden/cs.utexas.edu_~rossbach_cs380p_lab_kmeans-sample-inputs_random-n2048-d16-c16-answer.txt"),
    ("input/cs.utexas.edu_~rossbach_cs380p_lab_kmeans-sample-inputs_random-n16384-d24-c16.txt", 16, 24, 16384, "golden/cs.utexas.edu_~rossbach_cs380p_lab_kmeans-sample-inputs_random-n16384-d24-c16-answer.txt"),
    ("input/cs.utexas.edu_~rossbach_cs380p_lab_kmeans-sample-inputs_random-n65536-d32-c16.txt", 16, 32, 65536, "golden/cs.utexas.edu_~rossbach_cs380p_lab_kmeans-sample-inputs_random-n65536-d32-c16-answer.txt"),
    ("input/generated_input_n2013_d15_c13.txt", 13, 15, 2013, ""),
]
def compile():
    subprocess.run(["mkdir", "-p", "result"])
    subprocess.run(["make", "clean"])
    subprocess.run(["make", "all"])

def get_output_name(cmd, input):
    return f"result/{cmd}_{input[3]}"

def get_elapse(file):
    with open(file) as f:
        line = f.readline()
        time = line.split(",")[1]
        return float(time)
    
def get_output_label_name(cmd, input):
    return f"result/{cmd}_{input[3]}_label"

def run(program):
    for i in range(len(input)):
        elapse = 0.0
        my_input = input[i]
        output_file = get_output_name(program, my_input)
        cmd = f"./{program} -t {TOL} -k {my_input[1]} -d {my_input[2]} -i {my_input[0]} -m {ITER} -s {SEED} -c > {output_file}"
        for _ in range(REPEAT):
            subprocess.run(cmd, shell=True)
            time.sleep(0.5)
            elapse += get_elapse(output_file)
        output_label_file = get_output_label_name(program, my_input)
        label_cmd = f"./{program} -t {TOL} -k {my_input[1]} -d {my_input[2]} -i {my_input[0]} -m {ITER} -s {SEED} > {output_label_file}"
        subprocess.run(label_cmd, shell=True)
        elapse /= REPEAT
        print(f"{output_file}: {elapse}")
        answer = my_input[4]
        if (answer != ""):
            cmp_file(output_file, answer)

def cmp_all_label_file(program1, program2):
    for i in range(len(input)):
        cmp_label_file(get_output_label_name(program1, input[i]), get_output_label_name(program2, input[i]))


def main():
    compile()
    run("sequential")
    run("cuda_basic")
    run("cuda_shmem")
    run("thrust")
    cmp_all_label_file("cuda_basic", "sequential")
    cmp_all_label_file("cuda_shmem", "sequential")
    cmp_all_label_file("thrust", "sequential")
    cmp_file(get_output_name("cuda_basic", input[3]), get_output_name("sequential", input[3]))
    cmp_file(get_output_name("cuda_shmem", input[3]), get_output_name("sequential", input[3]))
    cmp_file(get_output_name("thrust", input[3]), get_output_name("sequential", input[3]))

if __name__ == "__main__":
    main()